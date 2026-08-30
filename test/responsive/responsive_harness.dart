// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE / COMPATIBILITY HARNESS
// ─────────────────────────────────────────────────────────────────────────────
//
// Pumps a widget across a matrix of (device size × text scale) and fails the
// test if any RenderFlex / Wrap / Table etc. reports a layout overflow (the
// yellow-and-black striped bar users would see, "BOTTOM OVERFLOWED BY N
// PIXELS").
//
// WHAT IT CATCHES
//   • Row / Column / Wrap / Flex overflow — the overwhelming majority of
//     real-world "it looks broken on my phone" reports.
//   • Overflow triggered ONLY at a larger accessibility font size or on a
//     wide viewport (tablet / unfolded foldable / split-screen).
//
// WHAT IT DOES NOT CATCH (yet)
//   • Pure Text clipping with no maxLines — Flutter fades/clips it silently,
//     no error is thrown. Those are softer ("...name cut off") bugs; a later
//     pass can add RenderParagraph inspection.
//   • Widgets drawn under the status/nav bar (edge-to-edge) — that's a
//     SafeArea audit, handled separately.
//
// HOW OVERFLOW IS DETECTED
//   RenderFlex computes its overflow in performLayout and, on the next paint,
//   calls FlutterError.reportError exactly once with a message containing
//   "overflowed". We temporarily install our own FlutterError.onError to
//   collect those, and forward every OTHER error to the previous handler so a
//   genuine bug still fails the test normally.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

/// One entry in the device matrix. [size] is logical (dp); [dpr] is the
/// device pixel ratio only used to derive a realistic physical size.
class ResponsiveDevice {
  final String label;
  final Size size;
  final double dpr;
  const ResponsiveDevice(this.label, this.size, this.dpr);
}

/// Representative Android form factors the app actually ships to
/// (minSdk 26, no Play Store screen filter, multi-window enabled).
const List<ResponsiveDevice> kResponsiveDevices = [
  // Small / old budget phone still allowed by minSdk 26.
  ResponsiveDevice('small_phone_320x640', Size(320, 640), 2.0),
  // The single most common bucket (Pixel-class, most Samsung A-series).
  ResponsiveDevice('baseline_360x800', Size(360, 800), 3.0),
  // Large modern phone (Pixel 8 Pro, S24+ class).
  ResponsiveDevice('large_phone_412x915', Size(412, 915), 2.625),
  // Foldable opened / small tablet / half-screen multi-window.
  ResponsiveDevice('foldable_open_673x841', Size(673, 841), 2.0),
  // 10" tablet.
  ResponsiveDevice('tablet_800x1280', Size(800, 1280), 2.0),
];

/// System font-scale settings a user can pick in Android Settings.
///   1.0  = default
///   1.3  = "Large"
///   1.6  = "Largest" (roughly; some OEMs go higher)
const List<double> kTextScales = [1.0, 1.3, 1.6];

/// Runs [build] through the full [devices] × [textScales] matrix.
///
/// Returns a map of `"<device> @<scale>x"` -> list of overflow messages.
/// An empty map means every combination laid out cleanly.
///
/// [wrap] lets a caller inject providers (GetX bindings, Theme, etc.) around
/// the widget under test — it receives the already-sized child.
Future<Map<String, List<String>>> collectResponsiveOverflows(
  WidgetTester tester, {
  Widget Function()? build,
  List<ResponsiveDevice> devices = kResponsiveDevices,
  List<double> textScales = kTextScales,
  Widget Function(Widget child)? wrap,
  // Set true for a widget whose real parent is a scroll view (e.g. a policy
  // block inside a details screen). Vertical growth is then expected and not
  // flagged; horizontal overflow still is.
  bool scrollable = false,
  // Full-tree override: given the text scale, returns the entire widget to
  // pump (must include its own Sizer + app root). Used by the screen-level
  // harness to pump a GetMaterialApp hosting a real screen. When set,
  // `build` / `wrap` / `scrollable` are ignored.
  Widget Function(double textScale)? appBuilder,
}) async {
  assert(
    build != null || appBuilder != null,
    'pass either build: or appBuilder:',
  );
  final failures = <String, List<String>>{};
  addTearDown(tester.view.reset);

  for (final device in devices) {
    for (final scale in textScales) {
      final key = '${device.label} @${scale}x';
      final overflows = <String>[];

      tester.view.devicePixelRatio = device.dpr;
      tester.view.physicalSize = Size(
        device.size.width * device.dpr,
        device.size.height * device.dpr,
      );

      final previousOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final full = details.toString();
        if (full.contains('overflowed') || full.contains('overflowing')) {
          // Ignore sub-pixel overflow (≤1px) — that's layout rounding
          // (Scaffold's body/bottom-bar CustomMultiChildLayout, etc.), it
          // never renders a visible stripe.
          final m = RegExp(r'overflowed by ([\d.]+) pixels').firstMatch(full);
          final px = m == null ? 99.0 : (double.tryParse(m.group(1)!) ?? 99.0);
          if (px > 1.0) overflows.add(_summariseOverflowError(details));
        } else if (_isIgnorableAssetError(full)) {
          // This harness tests LAYOUT, not asset availability. A widget that
          // points at an asset/URL that doesn't resolve in the test sandbox
          // still lays out (Flutter renders an empty box) — that's fine here.
        } else {
          previousOnError?.call(details);
        }
      };

      try {
        await tester.pumpWidget(
          appBuilder != null
              ? appBuilder(scale)
              : Sizer(
                  builder: (context, orientation, deviceType) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(scale),
                          ),
                          child: child!,
                        );
                      },
                      home: Scaffold(
                        body: Builder(
                          builder: (_) {
                            Widget content =
                                wrap == null ? build!() : wrap(build!());
                            if (scrollable) {
                              content = SingleChildScrollView(child: content);
                            }
                            return content;
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
        // A few pumps let post-frame layout / a first data frame / short
        // animations settle so their overflow (if any) is also reported.
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
      } catch (e) {
        overflows.add('threw during pump: $e');
      } finally {
        FlutterError.onError = previousOnError;
      }

      // Also sweep the render tree directly — belt and braces for cases where
      // the paint-time report was swallowed by an ancestor RepaintBoundary.
      _sweepRenderTreeForOverflow(tester, overflows);

      if (overflows.isNotEmpty) {
        failures[key] = overflows.toSet().toList();
      }
    }
  }

  return failures;
}

bool _isIgnorableAssetError(String s) {
  return s.contains('Unable to load asset') ||
      s.contains('resolving an image codec') ||
      s.contains('while resolving an image') ||
      s.contains('HttpException') ||
      s.contains('Invalid image data') ||
      (s.contains('NetworkImage') && s.contains('statusCode'));
}

String _summariseOverflowError(FlutterErrorDetails details) {
  final lines = details.toString().split('\n').map((l) => l.trim());
  final headline = lines.firstWhere(
    (l) => l.contains('overflowed'),
    orElse: () => 'overflow',
  );
  final widget = lines.firstWhere(
    (l) => l.startsWith('The relevant error-causing widget was'),
    orElse: () => '',
  );
  // The line after "error-causing widget was:" carries the widget + source loc.
  final all = details.toString().split('\n');
  var loc = '';
  for (var i = 0; i < all.length; i++) {
    if (all[i].contains('error-causing widget was') && i + 1 < all.length) {
      loc = all[i + 1].trim();
      break;
    }
  }
  return [headline, if (loc.isNotEmpty) 'at: $loc' else if (widget.isNotEmpty) widget]
      .join('  ');
}

void _sweepRenderTreeForOverflow(WidgetTester tester, List<String> sink) {
  for (final node in tester.allRenderObjects) {
    if (node is RenderFlex) {
      final overflow = _renderFlexOverflow(node);
      if (overflow != null && overflow > 1.0) {
        sink.add(
          'RenderFlex (${node.direction.name}) size=${_fmtSize(node.size)} '
          'overflowed by ${overflow.toStringAsFixed(1)}px  '
          '${_describeCreator(node)}  children=[${_describeChildren(node)}]',
        );
      }
    }
  }
}

String _fmtSize(Size s) =>
    '${s.width.toStringAsFixed(0)}x${s.height.toStringAsFixed(0)}';

String _describeChildren(RenderFlex flex) {
  final parts = <String>[];
  RenderBox? child = flex.firstChild;
  while (child != null) {
    final type = child.runtimeType.toString().replaceFirst('Render', '');
    final size = child.hasSize ? _fmtSize(child.size) : '?';
    final creator = child.debugCreator;
    var label = type;
    if (creator is DebugCreator) {
      label = creator.element.widget.runtimeType.toString();
    }
    parts.add('$label $size');
    final parentData = child.parentData;
    child = parentData is FlexParentData ? parentData.nextSibling : null;
  }
  return parts.join(', ');
}

/// Best-effort identification of which widget in app source created this
/// RenderObject, plus a couple of ancestor widget types for context.
String _describeCreator(RenderObject node) {
  final creator = node.debugCreator;
  if (creator is! DebugCreator) return '';
  Element? el = creator.element;
  final ancestors = <String>[];
  var hops = 0;
  el.visitAncestorElements((ancestor) {
    ancestors.add(ancestor.widget.runtimeType.toString());
    return ++hops < 6;
  });
  return '(${el.widget.runtimeType} inside ${ancestors.join(' < ')})';
}

/// RenderFlex keeps its overflow in a private field; the only public tell is
/// the debug paint. We reconstruct it from the layout instead: sum of child
/// main-axis extents vs. the flex's own main-axis size.
double? _renderFlexOverflow(RenderFlex flex) {
  if (!flex.hasSize) return null;
  final isHorizontal = flex.direction == Axis.horizontal;
  double childrenExtent = 0;
  RenderBox? child = flex.firstChild;
  while (child != null) {
    if (child.hasSize) {
      childrenExtent += isHorizontal ? child.size.width : child.size.height;
    }
    final parentData = child.parentData;
    child = parentData is FlexParentData ? parentData.nextSibling : null;
  }
  final own = isHorizontal ? flex.size.width : flex.size.height;
  final diff = childrenExtent - own;
  return diff > 0 ? diff : null;
}

/// Convenience: assert the matrix is clean, with a readable failure report.
void expectNoResponsiveOverflow(Map<String, List<String>> failures) {
  if (failures.isEmpty) return;
  final buffer = StringBuffer('Responsive overflow detected:\n');
  failures.forEach((combo, messages) {
    buffer.writeln('  • $combo');
    for (final m in messages) {
      buffer.writeln('      - $m');
    }
  });
  fail(buffer.toString());
}
