import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? fallbackImageUrl;
  final String? thumbnailImageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const ChewieVideoPlayer({
    super.key,
    required this.videoUrl,
    this.fallbackImageUrl,
    this.thumbnailImageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isLoading = true;
  bool _showThumbnail = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Returns true if the URL is a direct streamable video file.
  /// Instagram, YouTube, and other social URLs cannot be played by ExoPlayer.
  bool _isStreamableUrl(String url) {
    if (url.isEmpty) return false;
    const blocked = [
      'instagram.com',
      'youtu.be',
      'youtube.com',
      'tiktok.com',
      'facebook.com',
      'twitter.com',
      'x.com',
    ];
    final lower = url.toLowerCase();
    return !blocked.any((host) => lower.contains(host));
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl.isEmpty || !_isStreamableUrl(widget.videoUrl)) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _showThumbnail = false;
        });
      }
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoController!.initialize();

      // Only proceed if widget is still mounted
      if (!mounted) {
        _videoController?.dispose();
        return;
      }

      // Mute the audio
      await _videoController!.setVolume(0);

      // Set looping
      await _videoController!.setLooping(true);

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        allowFullScreen: false,
        allowMuting: true,
        autoInitialize: true,

        // These properties ensure video fills the container
        aspectRatio: _videoController!.value.aspectRatio,
        allowPlaybackSpeedChanging: false,

        // Stretch to fill container
        deviceOrientationsOnEnterFullScreen: null,

        // Customize display
        showOptions: false,
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: Colors.transparent,
          handleColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          bufferedColor: Colors.transparent,
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.transparent,
          handleColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          bufferedColor: Colors.transparent,
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _showThumbnail = false;
        });
      }
    } catch (e) {
      debugPrint("Chewie Video Error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _showThumbnail = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ChewieVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      // Dispose old controllers
      _chewieController?.dispose();
      _videoController?.dispose();

      // Reset state
      _hasError = false;
      _isLoading = true;
      _showThumbnail = true;
      _chewieController = null;
      _videoController = null;

      // Initialize new video
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show thumbnail while loading or before video starts
    if (_showThumbnail && widget.thumbnailImageUrl != null && widget.thumbnailImageUrl!.isNotEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Thumbnail image
            CustomNetworkImage(
              imageUrl: widget.thumbnailImageUrl!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            ),
            // Loading indicator overlay
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    if (_hasError || _chewieController == null) {
      // Show fallback image if video fails
      if (widget.fallbackImageUrl != null && widget.fallbackImageUrl!.isNotEmpty) {
        return CustomNetworkImage(
          imageUrl: widget.fallbackImageUrl!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      }
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Icon(Icons.video_library, color: Colors.grey),
      );
    }

    // Use ClipRect to ensure video fills the container completely
    return ClipRect(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      ),
    );
  }
}