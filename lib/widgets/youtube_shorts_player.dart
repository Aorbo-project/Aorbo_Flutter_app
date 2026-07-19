import 'dart:async';

import 'package:arobo_app/utils/youtube_utils.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Embeds a YouTube video inside a fixed-size container via the official
/// IFrame Player API. In ambient mode (default) playback is driven purely
/// by on-screen visibility — it starts muted and looping once the
/// container is mostly in view (Reels/Shorts-style feed autoplay) and
/// pauses again once it scrolls away, so a carousel/grid of these never
/// has more than one or two videos actually playing at a time.
///
/// Set [autoPlayWhenVisible] to false for a single full-screen player
/// (e.g. inside a modal) that should just start playing immediately.
///
/// Pass [externalActive] when the caller already knows which item should
/// be playing — e.g. a PageView's current page — instead of leaving it to
/// on-screen visibility geometry. This matters for carousels where several
/// pages are simultaneously mounted but only one is meant to be "current":
/// visibility fractions alone can't tell those apart reliably.
class YoutubeShortsPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  /// YouTube's IFrame player has no way to auto-detect a video's true
  /// orientation — a regular `/watch` upload and a `/shorts/` upload look
  /// identical to the embed API. The caller must say which one this is
  /// (e.g. via [isYoutubeShortsUrl]) so the player frame is sized 9:16
  /// instead of always assuming 16:9 — forcing the wrong ratio here is
  /// exactly what produces visible pillar/letterboxing.
  final bool isVertical;
  final bool autoPlayWhenVisible;
  final bool? externalActive;
  final bool initiallyMuted;
  final bool showMuteToggle;
  final bool showYoutubeControls;

  /// WebView-based players intercept touches for their own web content
  /// (tap-to-pause, drag-to-seek, "Watch on YouTube" links) at the page's
  /// own JavaScript layer — before a parent scroller ever sees them. That
  /// happens below Flutter's gesture arena entirely, so no combination of
  /// `gestureRecognizers`/`IgnorePointer` on the player can stop it. False
  /// (default) additionally stacks an opaque Flutter-side layer directly
  /// over the player so the platform view underneath never receives the
  /// touch in the first place, guaranteeing swipes/taps pass through to
  /// whatever sits behind it. Set true only for a dedicated full-screen
  /// player the user is meant to touch directly.
  final bool interactive;

  /// YouTube's IFrame player always letterboxes its native frame within
  /// whatever box it's given — it has no "cover/crop" mode via the public
  /// API — so this fills any leftover space around the frame.
  final Color backgroundColor;

  const YoutubeShortsPlayer({
    super.key,
    required this.videoUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.isVertical = true,
    this.thumbnailUrl,
    this.autoPlayWhenVisible = true,
    this.externalActive,
    this.initiallyMuted = true,
    this.showMuteToggle = true,
    this.showYoutubeControls = false,
    this.interactive = false,
    this.backgroundColor = Colors.black,
  });

  @override
  State<YoutubeShortsPlayer> createState() => _YoutubeShortsPlayerState();
}

class _YoutubeShortsPlayerState extends State<YoutubeShortsPlayer>
    with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _stateSubscription;
  Timer? _visibilityDebounce;
  late bool _isMuted = widget.initiallyMuted;
  bool _isVisible = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final videoId = extractYoutubeVideoId(widget.videoUrl);
    if (videoId == null) {
      _hasError = true;
      return;
    }

    // `autoPlay: true` routes through the package's `loadVideoById` — load
    // and play in one JS call. Cueing first (`autoPlay: false`) and firing
    // a separate `playVideo()` afterward was two calls racing against the
    // same "player ready" gate instead of one, and on a freshly mounted
    // card (recreated from scratch every time it becomes active) that
    // extra hop was enough to leave it stuck on the paused/thumbnail
    // state.
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: widget.externalActive ?? !widget.autoPlayWhenVisible,
      params: YoutubePlayerParams(
        showControls: widget.showYoutubeControls,
        showFullscreenButton: false,
        mute: widget.initiallyMuted,
        loop: false, // YouTube's loop=1 alone does not loop a single cued
        // video (it needs a matching `playlist` param); looping is
        // driven manually below via the `ended` state instead.
        playsInline: true,
        enableCaption: false,
        strictRelatedVideos: true,
      ),
    );
    _controller = controller;

    _stateSubscription = controller.stream.listen((value) {
      if (value.playerState == PlayerState.ended) {
        controller.seekTo(seconds: 0);
        controller.playVideo();
      }
    });
  }

  @override
  void didUpdateWidget(YoutubeShortsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (controller == null || widget.externalActive == null) return;
    if (widget.externalActive == oldWidget.externalActive) return;
    widget.externalActive! ? controller.playVideo() : controller.pauseVideo();
  }

  // A backgrounded app should never keep a video (and its audio/decoder)
  // running just because the widget itself never left the tree.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state != AppLifecycleState.resumed) {
      controller.pauseVideo();
    } else if (widget.externalActive ?? _isVisible) {
      controller.playVideo();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // When the parent drives playback explicitly (e.g. a PageView's
    // current-page index), on-screen visibility fractions are irrelevant —
    // several pages can be simultaneously "visible" without any one of
    // them being the intended active item.
    if (widget.externalActive != null || !widget.autoPlayWhenVisible) return;

    final visible = info.visibleFraction > 0.6;
    if (visible == _isVisible) return;

    // Debounce: ignore fractions that flip back within 400ms — avoids
    // tearing playback down and restarting it on transient scroll jitter.
    _visibilityDebounce?.cancel();
    _visibilityDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || _controller == null) return;
      _isVisible = visible;
      visible ? _controller!.playVideo() : _controller!.pauseVideo();
    });
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _isMuted = !_isMuted);
    _isMuted ? controller.mute() : controller.unMute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _visibilityDebounce?.cancel();
    _stateSubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError || controller == null) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: CustomNetworkImage(
          imageUrl: widget.thumbnailUrl ?? '',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    return VisibilityDetector(
      key: Key('youtube-short-${widget.videoUrl}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: widget.backgroundColor),
              // YouTube's IFrame player always letterboxes its frame within
              // whatever box it's given (it doesn't crop-to-fill), so
              // "cover" isn't achievable by resizing the outer box — this
              // renders the true frame, centered, on backgroundColor, at
              // the video's real orientation so a vertical Short doesn't
              // get squeezed into a horizontal 16:9 frame (and vice versa).
              Center(
                child: AspectRatio(
                  aspectRatio: widget.isVertical ? 9 / 16 : 16 / 9,
                  child: YoutubePlayer(
                    controller: controller,
                    // Both default to true and set up their own internal
                    // drag-gesture handling that competes for the gesture
                    // arena — an empty set tells the player not to claim
                    // drags for itself. This alone does NOT stop the
                    // embedded page's own JS touch handling (see the
                    // opaque overlay below, which is what actually works).
                    enableFullScreenOnVerticalDrag: false,
                    autoFullScreen: false,
                    gestureRecognizers:
                        const <Factory<OneSequenceGestureRecognizer>>{},
                  ),
                ),
              ),
              // Belt-and-suspenders: the embedded WebView is a native
              // platform view with its own JavaScript touch handling
              // (tap-to-pause, drag-to-seek) that can swallow a touch
              // before Flutter's gesture arena ever sees it — most
              // aggressively exactly while a video is playing. An opaque,
              // empty-handler layer stacked directly on top stops the hit
              // test here every time, so the platform view underneath
              // never receives the touch at all and the ancestor
              // PageView's own drag recognizer is free to claim it.
              if (!widget.interactive)
                Positioned.fill(
                  child: GestureDetector(behavior: HitTestBehavior.opaque),
                ),
              if (widget.showMuteToggle)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
