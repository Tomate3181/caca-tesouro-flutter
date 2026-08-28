import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/proximity_state.dart';

/// Widget de ondas de radar tátil animadas com efeito de pulso térmico
class TactileRadarWidget extends StatefulWidget {
  final ProximityState state;
  final Widget child;

  const TactileRadarWidget({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  State<TactileRadarWidget> createState() => _TactileRadarWidgetState();
}

class _TactileRadarWidgetState extends State<TactileRadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant TactileRadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ajusta a velocidade da animação conforme a proximidade
    if (widget.state == ProximityState.veryHot) {
      _controller.duration = const Duration(milliseconds: 800);
      if (!_controller.isAnimating) _controller.repeat();
    } else if (widget.state == ProximityState.hot) {
      _controller.duration = const Duration(milliseconds: 1400);
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.duration = const Duration(milliseconds: 2400);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRadarActive = widget.state.isTactileRadarActive;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RadarPulsePainter(
            animationValue: _controller.value,
            color: widget.state.color,
            isActive: isRadarActive,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isActive;

  _RadarPulsePainter({
    required this.animationValue,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.65;

    // Desenha 3 anéis concêntricos em expansão
    for (int i = 0; i < 3; i++) {
      final ringProgress = (animationValue + (i * 0.33)) % 1.0;
      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - ringProgress) + 1.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.isActive != isActive;
  }
}
