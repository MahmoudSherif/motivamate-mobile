import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpaceBackground extends StatefulWidget {
  final Widget child;
  
  const SpaceBackground({
    super.key,
    required this.child,
  });

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _generateStars();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _generateStars() {
    final random = math.Random();
    _stars = List.generate(150, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.8 + 0.2,
        speed: random.nextDouble() * 0.5 + 0.1,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Space background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 2.0,
                colors: [
                  Color(0xFF1A1A2E), // Dark purple nebula
                  Color(0xFF16213E), // Darker blue
                  Color(0xFF0A0A0A), // Very dark space
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Animated stars
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: StarsPainter(_stars, _controller.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          
          // Nebula effect overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.3),
                  Colors.transparent,
                  const Color(0xFF16213E).withOpacity(0.2),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;
  final double twinkleSpeed;
  
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  
  StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      // Calculate moving position
      final moveOffset = animationValue * star.speed * 100;
      var currentX = (star.x * size.width + moveOffset) % size.width;
      var currentY = (star.y * size.height + moveOffset * 0.3) % size.height;
      
      // Twinkle effect
      final twinkle = (math.sin(animationValue * star.twinkleSpeed * 2 * math.pi) + 1) / 2;
      final currentOpacity = star.opacity * twinkle;
      
      paint.color = Colors.white.withOpacity(currentOpacity);
      
      // Draw star as a small circle
      canvas.drawCircle(
        Offset(currentX, currentY),
        star.size,
        paint,
      );
      
      // Add cross effect for larger stars
      if (star.size > 2) {
        paint.strokeWidth = 0.5;
        paint.style = PaintingStyle.stroke;
        
        // Horizontal line
        canvas.drawLine(
          Offset(currentX - star.size * 2, currentY),
          Offset(currentX + star.size * 2, currentY),
          paint,
        );
        
        // Vertical line
        canvas.drawLine(
          Offset(currentX, currentY - star.size * 2),
          Offset(currentX, currentY + star.size * 2),
          paint,
        );
        
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Glass morphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.opacity = 0.2,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Import for ImageFilter
import 'dart:ui';