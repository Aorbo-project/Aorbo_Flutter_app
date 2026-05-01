import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/models/shorts_treks_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../widgets/chewie_video_player.dart';

class TrekShortsScreen extends StatelessWidget {
  const TrekShortsScreen({Key? key}) : super(key: key);

  void _showVideoPopup(BuildContext context, String videoUrl, String thumbnailUrl) {
    VideoPlayerController? videoController;
    ChewieController? chewieController;

    // Initialize video player
    videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Initialize Chewie controller without controls
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: true,
          looping: false,
          showControls: false, // No playback controls
          showControlsOnInitialize: false,
          allowFullScreen: false,
          allowMuting: false,
          deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft],
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          autoInitialize: true,
          customControls: const SizedBox.shrink(), // Empty controls
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                    SizedBox(height: 10),
                    Text(
                      'Error playing video',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: () {
              // Close dialog on tap
              Navigator.of(context).pop();
            },
            child: Stack(
              children: [
                // Chewie Video Player
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                    child: Chewie(
                      controller: chewieController!,
                    ),
                  ),
                ),
                // Close button hint
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tap anywhere to close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Cleanup when dialog is closed
      if (chewieController != null) {
        chewieController!.pause();
        chewieController!.dispose();
      }
      if (videoController != null) {
        videoController!.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _dashboardC = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Trek Shorts',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final shortsLoading = _dashboardC.shortsTreksObserver.value
            .maybeWhen(loading: (data) => true, orElse: () => false);
        List<ShortsTreksData>? shortsTreksCardsData = _dashboardC
            .shortsTreksObserver.value
            .maybeWhen(
          success: (shortsTreksResponse) {
            return [
              ShortsTreksData(title: "cvubvghf  gjvhbun",description: "4M",textColour: "#ffffff",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/image%20(9).png?alt=media&token=a173b677-2c64-47b9-b610-6f8bad60650f",videoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.47.14%20PM.mp4?alt=media&token=d6f20c28-3369-415b-8859-5a02dad8113a",shortVideoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.46.02%20PM.mp4?alt=media&token=356e3d97-dfc9-4360-8a98-118a0b60a5c3"),
              ShortsTreksData(title: "hgvjhbkjnllbhjg h",description: "5M",textColour: "#35323b",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/image%20(9).png?alt=media&token=a173b677-2c64-47b9-b610-6f8bad60650f",videoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.47.14%20PM.mp4?alt=media&token=d6f20c28-3369-415b-8859-5a02dad8113a",shortVideoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.46.02%20PM.mp4?alt=media&token=356e3d97-dfc9-4360-8a98-118a0b60a5c3"),
            ];
            return (shortsTreksResponse as ShortsTreksDataResponseModel).data;
          },
          error: (sc) => [],
          orElse: () => [
            ShortsTreksData(),
            ShortsTreksData(),
            ShortsTreksData(),
            ShortsTreksData()
          ],
        );
        if (shortsTreksCardsData?.isEmpty == true) return SizedBox();
        return Padding(
          padding: EdgeInsets.all(2.h),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.7,
            ),
            itemCount: shortsTreksCardsData?.length,
            itemBuilder: (context, index) {
              final cardData = shortsTreksCardsData?[index];
              return GestureDetector(
                onTap: () {
                  if (cardData?.videoPath != null && cardData!.videoPath!.isNotEmpty) {
                    _showVideoPopup(
                        context,
                        cardData.videoPath!,
                        cardData.imagePath ?? ""
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5.h),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.5.h),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image/Video thumbnail
                        ChewieVideoPlayer(
                          videoUrl: cardData?.shortVideoPath ?? "",
                          thumbnailImageUrl: cardData?.imagePath ?? "", // Shows while loading
                          fallbackImageUrl: cardData?.imagePath ?? "", // Shows on error
                          fit: BoxFit.cover,
                          width: 100.w,
                          height: 50.h,
                        ),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(1.5.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardData?.description ??
                                    'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 6.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${cardData?.title ?? '4M'}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 6.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );},
      ),
    );
  }
}