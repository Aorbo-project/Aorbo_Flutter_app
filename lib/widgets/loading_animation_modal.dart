import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

class Particle {
  late Offset position;
  late Color color;
  late double speed;
  late double angle;
  late double size;
  late double alpha;
  late double gravity;

  Particle({
    required Offset origin,
    required this.color,
  }) {
    position = origin; // Particles start exactly at the origin
    // Initial speed for a focused burst, slightly higher
    speed = math.Random().nextDouble() * 25 + 30; // Speed between 30 and 55
    // Full random angle distribution (0 to 360 degrees)
    angle = math.Random().nextDouble() * math.pi * 2;

    size = math.Random().nextDouble() * 2 + 1; // Size between 1 and 3
    alpha = 1.0;
    gravity = math.Random().nextDouble() * 0.5 +
        0.2; // Gravity between 0.2 and 0.7 (less gravity)
  }

  void update() {
    // Apply velocity components based on angle and current speed
    double deltaX = math.cos(angle) *
        speed *
        0.1; // Increased multiplier for a slightly wider initial spread again
    double deltaY = math.sin(angle) * speed * 0.1 + gravity; // Apply gravity

    position += Offset(deltaX, deltaY);

    // Decay speed over time
    speed *= 0.98; // Slower speed decay for longer travel

    // Fade out
    alpha -= 0.007; // Slightly slower fade out for longer visibility
    if (alpha < 0) alpha = 0;
  }
}

class LoadingAnimationModal extends StatefulWidget {
  const LoadingAnimationModal({super.key});

  @override
  State<LoadingAnimationModal> createState() => _LoadingAnimationModalState();
}

class _LoadingAnimationModalState extends State<LoadingAnimationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  bool _showSuccess = false;

  final List<Particle> _particles = [];
  final List<Color> _particleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1500), // Duration for loading animation
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      // Keep rotation for loading
      begin: 0,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _opacityAnimation = Tween<double>(
      // Opacity for the success checkmark fade-in
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5,
            curve: Curves
                .easeIn), // Fade in during the first half of success animation
      ),
    );

    // Start loading animation
    _animationController.repeat();
    _startLoadingAnimation();
  }

  void _createParticles(Offset origin) {
    _particles.clear(); // Clear previous particles if any
    for (int i = 0; i < 400; i++) {
      // Increased particle count for a denser burst
      _particles.add(
        Particle(
          origin: origin,
          color: _particleColors[math.Random().nextInt(_particleColors.length)],
        ),
      );
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
    }
    _particles.removeWhere((particle) => particle.alpha <= 0);
  }

  void _startLoadingAnimation() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _animationController.stop(); // Stop loading animation

      // Get the center of the screen where the success icon will appear
      final renderBox = context.findRenderObject() as RenderBox?;
      Offset center = Offset.zero;
      if (renderBox != null) {
        center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
      }

      setState(() {
        _showSuccess = true;
        _animationController.duration = const Duration(
            milliseconds: 800); // Increased duration for success animation
        _animationController.forward(
            from: 0.0); // Start success animation from beginning
        _createParticles(
            center); // Create particles at this central point right when success state is set
      });

      // Animate particles
      Future.doWhile(() async {
        if (!mounted) return false;
        if (_particles.isEmpty)
          return false; // Stop animation if no particles left
        setState(() {
          _updateParticles();
        });
        await Future.delayed(const Duration(milliseconds: 16)); // ~60 FPS
        return true; // Continue as long as mounted and particles exist
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black54, // Semi-transparent overlay
        child: Stack(
          children: [
            // Confetti particles (drawn behind the main content)
            if (_showSuccess && _particles.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: ConfettiPainter(particles: _particles),
                ),
              ),
            // Main content (loading/success animation and text)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(
                        milliseconds:
                            400), // Duration for switching between loading/success widgets
                    child: _showSuccess
                        ? FadeTransition(
                            opacity: _opacityAnimation,
                            child: ScaleTransition(
                              scale:
                                  _scaleAnimation, // Scale animation applies to the success icon
                              child: Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: CommonColors
                                      .radioBtnGradient, // Gradient for success circle
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 15.w,
                                ),
                              ),
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value *
                                    math.pi *
                                    2, // Full rotation for loading circle
                                child: ScaleTransition(
                                  scale:
                                      _scaleAnimation, // Scale animation applies to the loading circle
                                  child: Container(
                                    width: 20.w,
                                    height: 20.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.8),
                                        width: 3,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(2.w),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 4.h),
                  AnimatedSwitcher(
                    duration: const Duration(
                        milliseconds: 300), // Duration for text switching
                    child: Text(
                      _showSuccess ? 'Success!' : 'Processing...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  AnimatedOpacity(
                    duration: const Duration(
                        milliseconds: 300), // Duration for text opacity change
                    opacity: _showSuccess ? 1.0 : 0.7,
                    child: Text(
                      _showSuccess
                          ? 'Your adventure awaits!'
                          : 'Please wait...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
