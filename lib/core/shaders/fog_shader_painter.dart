import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Painter responsável por desenhar o Fragment Shader GLSL
class FogShaderPainter extends CustomPainter {
  final ui.FragmentShader? shader;
  final double time;
  final double intensity; // 0.0 a 1.0

  FogShaderPainter({
    required this.shader,
    required this.time,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shader != null) {
      // Passa os uniforms para o Fragment Shader:
      // uniform vec2 uSize; (índices 0 e 1)
      shader!.setFloat(0, size.width);
      shader!.setFloat(1, size.height);
      // uniform float uTime; (índice 2)
      shader!.setFloat(2, time);
      // uniform float uIntensity; (índice 3)
      shader!.setFloat(3, intensity);

      final paint = Paint()..shader = shader;
      canvas.drawRect(Offset.zero & size, paint);
    } else {
      // Fallback gracioso com gradiente animado se o shader nativo não estiver compilado
      final clampedIntensity = intensity.clamp(0.0, 1.0);
      final currentBaseColor = Color.lerp(
        AppConstants.colorCold,
        AppConstants.colorHot,
        clampedIntensity,
      )!;

      final darkerTone = Color.lerp(
        currentBaseColor,
        Colors.black,
        0.5,
      )!;

      final rect = Offset.zero & size;
      final gradient = RadialGradient(
        center: Alignment(
          0.0 + 0.2 * ui.lerpDouble(-1, 1, (time % 4) / 4)!,
          -0.2 + 0.1 * ui.lerpDouble(-1, 1, ((time + 2) % 4) / 4)!,
        ),
        radius: 1.2 + 0.3 * clampedIntensity,
        colors: [
          currentBaseColor.withValues(alpha: 0.85),
          darkerTone,
          AppConstants.colorDarkBg,
        ],
        stops: const [0.0, 0.65, 1.0],
      );

      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FogShaderPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.intensity != intensity ||
        oldDelegate.shader != shader;
  }
}
