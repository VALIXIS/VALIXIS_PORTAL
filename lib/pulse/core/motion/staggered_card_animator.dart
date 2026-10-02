import 'package:flutter/material.dart';
import '../theme/pulse_theme.dart';
import 'fluid_animation_controller.dart';

class StaggeredCardAnimator extends StatefulWidget {
  final Widget child;
  final int index;
  final int totalCount;
  final Duration duration;

  const StaggeredCardAnimator({
    super.key,
    required this.child,
    this.index = 0,
    this.totalCount = 4,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<StaggeredCardAnimator> createState() => _StaggeredCardAnimatorState();
}

class _StaggeredCardAnimatorState extends State<StaggeredCardAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = FluidAnimationController.createStaggeredAnimation(
      parent: _controller,
      index: widget.index,
      totalItems: widget.totalCount,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = _animation.value.clamp(0.0, 1.0);
        final translateY = (1.0 - _animation.value) * 30.0;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Opacity(
            opacity: opacity,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: PulseColors.electricCyan.withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
