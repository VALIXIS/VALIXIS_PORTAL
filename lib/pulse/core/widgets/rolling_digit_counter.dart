import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RollingDigitCounter extends StatefulWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final TextStyle style;
  final Duration duration;

  const RollingDigitCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<RollingDigitCounter> createState() => _RollingDigitCounterState();
}

class _RollingDigitCounterState extends State<RollingDigitCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RollingDigitCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: widget.decimalPlaces,
    );
    return formatter.format(val).trim();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formattedNum = _formatValue(_animation.value);
        return Text(
          '${widget.prefix}$formattedNum${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
