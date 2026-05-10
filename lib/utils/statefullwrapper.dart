import 'package:flutter/cupertino.dart';
import 'package:focus_detector/focus_detector.dart';


class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;
  final Function? onStart;
  final Function? onEnd;

  const StatefulWrapper(
      {super.key,
        required this.onInit,
        required this.child,
        this.onStart,
        this.onEnd});

  @override
  State<StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onFocusGained() {
    widget.onStart?.call();
  }

  void onFocusEnd() {
    widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: onFocusGained,
      onFocusLost: onFocusEnd,
      child: widget.child,
    );
  }
}