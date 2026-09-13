import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// System operational state for the 3D Core visual feedback.
enum CoreSystemState {
  nominal,
  syncing,
  alert,
}

/// A signature architectural 3D interactive command core for the VALIXIS Portal.
///
/// Projects a mathematical 3D polyhedral geometric crystal with orbiting
/// telemetry rings and depth-sorted vector vertices.
/// Features mouse parallax tracking, inertial rotation, and state-reactive illumination.
class ValixisCommandCore3D extends StatefulWidget {
  const ValixisCommandCore3D({
    super.key,
    this.size = 140.0,
    this.systemState = CoreSystemState.nominal,
    this.enableParallax = true,
    this.interactive = true,
  });

  final double size;
  final CoreSystemState systemState;
  final bool enableParallax;
  final bool interactive;

  @override
  State<ValixisCommandCore3D> createState() => _ValixisCommandCore3DState();
}

class _ValixisCommandCore3DState extends State<ValixisCommandCore3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset _pointerOffset = Offset.zero;
  Offset _targetParallax = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final primaryGlow = switch (widget.systemState) {
      CoreSystemState.nominal => AppColors.brandCyan,
      CoreSystemState.syncing => AppColors.brandBlue,
      CoreSystemState.alert => AppColors.warning,
    };

    final secondaryGlow = switch (widget.systemState) {
      CoreSystemState.nominal => AppColors.brandPurple,
      CoreSystemState.syncing => AppColors.brandCyan,
      CoreSystemState.alert => AppColors.error,
    };

    Widget coreWidget = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = reduceMotion ? 0.0 : _controller.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ValixisCorePainter(
            rotationProgress: progress,
            parallaxOffset: _pointerOffset,
            primaryColor: primaryGlow,
            secondaryColor: secondaryGlow,
            isSyncing: widget.systemState == CoreSystemState.syncing,
          ),
        );
      },
    );

    if (!widget.interactive || reduceMotion) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: coreWidget),
      );
    }

    return MouseRegion(
      onHover: (event) {
        if (!widget.enableParallax) return;
        final halfSize = widget.size / 2;
        final local = event.localPosition;
        final normalizedX = ((local.dx - halfSize) / halfSize).clamp(-1.0, 1.0);
        final normalizedY = ((local.dy - halfSize) / halfSize).clamp(-1.0, 1.0);
        setState(() {
          _targetParallax = Offset(normalizedX * 0.35, normalizedY * 0.35);
          _pointerOffset = Offset.lerp(_pointerOffset, _targetParallax, 0.25)!;
        });
      },
      onExit: (_) {
        setState(() {
          _targetParallax = Offset.zero;
          _pointerOffset = Offset.lerp(_pointerOffset, Offset.zero, 0.25)!;
        });
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: coreWidget),
      ),
    );
  }
}

/// High-performance 3D vector & depth-projection painter.
class _ValixisCorePainter extends CustomPainter {
  _ValixisCorePainter({
    required this.rotationProgress,
    required this.parallaxOffset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isSyncing,
  });

  final double rotationProgress;
  final Offset parallaxOffset;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isSyncing;

  // Pre-allocated Paint objects to guarantee zero garbage collection per frame
  final Paint _edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _vertexPaint = Paint()..style = PaintingStyle.fill;
  final Paint _ringPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;

  // Golden ratio for icosahedron vertices
  static final double _phi = (1.0 + math.sqrt(5.0)) / 2.0;

  // 12 vertices of regular icosahedron normalized
  static final List<List<double>> _baseVertices = [
    [-1, _phi, 0],
    [1, _phi, 0],
    [-1, -_phi, 0],
    [1, -_phi, 0],
    [0, -1, _phi],
    [0, 1, _phi],
    [0, -1, -_phi],
    [0, 1, -_phi],
    [_phi, 0, -1],
    [_phi, 0, 1],
    [-_phi, 0, -1],
    [-_phi, 0, 1],
  ];

  // 30 edges connecting vertices (pairs of indices)
  static const List<List<int>> _edges = [
    [0, 11], [0, 5], [0, 1], [0, 7], [0, 10],
    [1, 5], [5, 11], [11, 10], [10, 7], [7, 1],
    [3, 9], [3, 4], [3, 2], [3, 6], [3, 8],
    [4, 9], [2, 4], [6, 2], [8, 6], [9, 8],
    [4, 5], [5, 9], [8, 1], [1, 9], [7, 8],
    [7, 6], [6, 10], [2, 10], [2, 11], [4, 11],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width * 0.28;

    // Ambient radial core glow
    final glowRadius = size.width * 0.45;
    _glowPaint.shader = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: isSyncing ? 0.22 : 0.12),
        secondaryColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, _glowPaint);

    // Rotation angles
    final angleY = (rotationProgress * 2 * math.pi) + parallaxOffset.dx;
    final angleX = math.sin(rotationProgress * 2 * math.pi * 0.5) * 0.35 + parallaxOffset.dy;
    final angleZ = rotationProgress * math.pi * 0.25;

    // Orbiting telemetry ring 1
    _drawTelemetryRing(
      canvas: canvas,
      center: center,
      radius: size.width * 0.44,
      angleX: angleX + 0.5,
      angleY: angleY * 0.7,
      color: primaryColor.withValues(alpha: 0.3),
      strokeWidth: 1.0,
      activeNodes: 3,
    );

    // Orbiting telemetry ring 2 (orthogonal)
    _drawTelemetryRing(
      canvas: canvas,
      center: center,
      radius: size.width * 0.38,
      angleX: -angleX * 0.8,
      angleY: -angleY * 0.5 + 1.2,
      color: secondaryColor.withValues(alpha: 0.25),
      strokeWidth: 0.8,
      activeNodes: 2,
    );

    // Project 3D vertices to 2D screen coordinates with depth sorting
    final projected = <_ProjectedPoint>[];
    for (int i = 0; i < _baseVertices.length; i++) {
      final v = _baseVertices[i];
      // Normalize vector
      final len = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
      double x = (v[0] / len) * scale;
      double y = (v[1] / len) * scale;
      double z = (v[2] / len) * scale;

      // Rotate Y
      final cosY = math.cos(angleY);
      final sinY = math.sin(angleY);
      final x1 = x * cosY + z * sinY;
      final z1 = -x * sinY + z * cosY;

      // Rotate X
      final cosX = math.cos(angleX);
      final sinX = math.sin(angleX);
      final y2 = y * cosX - z1 * sinX;
      final z2 = y * sinX + z1 * cosX;

      // Rotate Z
      final cosZ = math.cos(angleZ);
      final sinZ = math.sin(angleZ);
      final x3 = x1 * cosZ - y2 * sinZ;
      final y3 = x1 * sinZ + y2 * cosZ;

      // Perspective projection
      final fov = scale * 4.0;
      final distance = fov / (fov + z2);
      final screenX = center.dx + x3 * distance;
      final screenY = center.dy + y3 * distance;

      projected.add(_ProjectedPoint(
        offset: Offset(screenX, screenY),
        depthZ: z2,
        index: i,
      ));
    }

    // Draw connecting edges with depth-based luminescence
    for (final edge in _edges) {
      final p1 = projected[edge[0]];
      final p2 = projected[edge[1]];
      final avgZ = (p1.depthZ + p2.depthZ) / 2.0;
      final normZ = ((avgZ / scale) + 1.0) / 2.0; // 0 (back) to 1 (front)
      final edgeAlpha = (0.15 + (normZ * 0.65)).clamp(0.08, 0.95);

      _edgePaint.color = Color.lerp(
        secondaryColor.withValues(alpha: edgeAlpha * 0.5),
        primaryColor.withValues(alpha: edgeAlpha),
        normZ,
      )!;
      _edgePaint.strokeWidth = 1.0 + (normZ * 1.2);

      canvas.drawLine(p1.offset, p2.offset, _edgePaint);
    }

    // Draw vertex nodes
    for (final pt in projected) {
      final normZ = ((pt.depthZ / scale) + 1.0) / 2.0;
      final nodeAlpha = (0.2 + (normZ * 0.8)).clamp(0.1, 1.0);
      final nodeRadius = 1.8 + (normZ * 2.2);

      _vertexPaint.color = primaryColor.withValues(alpha: nodeAlpha);
      canvas.drawCircle(pt.offset, nodeRadius, _vertexPaint);

      // Specular highlight on frontmost nodes
      if (normZ > 0.7) {
        _vertexPaint.color = Colors.white.withValues(alpha: (normZ - 0.7) * 2.5);
        canvas.drawCircle(pt.offset, nodeRadius * 0.5, _vertexPaint);
      }
    }
  }

  void _drawTelemetryRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angleX,
    required double angleY,
    required Color color,
    required double strokeWidth,
    required int activeNodes,
  }) {
    _ringPaint.color = color;
    _ringPaint.strokeWidth = strokeWidth;

    final path = Path();
    const steps = 36;
    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      final rx = math.cos(theta) * radius;
      final ry = math.sin(theta) * radius;

      // 3D rotation of ring
      final cosY = math.cos(angleY);
      final sinY = math.sin(angleY);
      final rx1 = rx * cosY;
      final rz1 = -rx * sinY;

      final cosX = math.cos(angleX);
      final sinX = math.sin(angleX);
      final ry2 = ry * cosX - rz1 * sinX;

      final screenPt = Offset(center.dx + rx1, center.dy + ry2);
      if (i == 0) {
        path.moveTo(screenPt.dx, screenPt.dy);
      } else {
        path.lineTo(screenPt.dx, screenPt.dy);
      }
    }
    canvas.drawPath(path, _ringPaint);

    // Draw small orbiting telemetry node pips along the ring
    for (int n = 0; n < activeNodes; n++) {
      final nodeProgress = (rotationProgress * (n + 1) * 0.7 + (n * (2 * math.pi / activeNodes))) % (2 * math.pi);
      final nx = math.cos(nodeProgress) * radius;
      final ny = math.sin(nodeProgress) * radius;

      final cosY = math.cos(angleY);
      final sinY = math.sin(angleY);
      final nx1 = nx * cosY;
      final nz1 = -nx * sinY;

      final cosX = math.cos(angleX);
      final sinX = math.sin(angleX);
      final ny2 = ny * cosX - nz1 * sinX;

      final nodePos = Offset(center.dx + nx1, center.dy + ny2);
      _vertexPaint.color = primaryColor.withValues(alpha: 0.85);
      canvas.drawCircle(nodePos, 2.0, _vertexPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ValixisCorePainter oldDelegate) {
    return oldDelegate.rotationProgress != rotationProgress ||
        oldDelegate.parallaxOffset != parallaxOffset ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.isSyncing != isSyncing;
  }
}

class _ProjectedPoint {
  _ProjectedPoint({
    required this.offset,
    required this.depthZ,
    required this.index,
  });

  final Offset offset;
  final double depthZ;
  final int index;
}
