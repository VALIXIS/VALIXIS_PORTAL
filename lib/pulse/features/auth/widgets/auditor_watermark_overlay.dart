import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuditorWatermarkOverlay extends StatelessWidget {
  final Widget child;

  const AuditorWatermarkOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuditor = authProvider.hasAuditorWatermark;

    if (!isAuditor) return child;

    return Stack(
      children: [
        child,
        // 1. Top Read-Only Compliance Banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFB74D).withOpacity(0.95),
                      const Color(0xFFF57C00).withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified_user_rounded, color: Colors.black, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AUDITOR READ-ONLY SESSION • COMPLIANCE AUDIT VAULT ACTIVE • MUTATIONS RESTRICTED',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Full-Canvas Diagonal Repeating Watermark Painter
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: WatermarkPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const watermarkText = 'AUDITOR READ-ONLY • COMPLIANCE VAULT';
    final textStyle = TextStyle(
      color: const Color(0xFFFFB74D).withOpacity(0.08),
      fontSize: 20,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
    );

    textPainter.text = TextSpan(text: watermarkText, style: textStyle);
    textPainter.layout();

    canvas.save();
    canvas.rotate(-25 * math.pi / 180);

    const stepX = 340.0;
    const stepY = 160.0;

    for (double y = -size.height; y < size.height * 2; y += stepY) {
      for (double x = -size.width; x < size.width * 2; x += stepX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
