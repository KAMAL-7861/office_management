import 'package:flutter/material.dart';

/// Custom map pin marker with a pulsing glow animation.
class EmployeeMapMarker extends StatelessWidget {
  final bool isCheckedIn;
  final Animation<double> pulseAnimation;

  const EmployeeMapMarker({
    super.key,
    required this.isCheckedIn,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isCheckedIn ? const Color(0xFF43A047) : const Color(0xFFE53935);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(pulseAnimation.value * 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isCheckedIn ? Icons.person : Icons.person_off,
                color: Colors.white,
                size: 22,
              ),
            );
          },
        ),
        // Pin tail
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(color: color),
        ),
      ],
    );
  }
}

/// Custom painter for the pin tail triangle.
class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
