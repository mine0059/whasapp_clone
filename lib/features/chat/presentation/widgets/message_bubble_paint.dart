import 'package:flutter/material.dart';

class MessageBubblePainter extends CustomPainter {
  final Color color;
  final bool isMe;

  MessageBubblePainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMe) {
      // Right-side bubble (my messages)
      path.addRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width - 10,
          size.height,
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(2),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
      );

      // Add the tail pointing right
      path.moveTo(size.width - 10, 10);
      path.lineTo(size.width, 0); // Points to top
      path.lineTo(size.width - 10, 0);
      path.close();
    } else {
      // Left-side bubble (other person's messages)
      path.addRRect(
        RRect.fromLTRBAndCorners(
          10,
          0,
          size.width,
          size.height,
          topLeft: const Radius.circular(0),
          topRight: const Radius.circular(18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
      );

      // Add the tail pointing left
      path.moveTo(10, 10);
      path.lineTo(0, 0); // Points to top
      path.lineTo(10, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
