import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../constants/app_constants.dart';
import 'fog_shader_painter.dart';

/// Widget que anima e renderiza o background térmico com Fragment Shader
class FogShaderBackground extends StatefulWidget {
  final double intensity; // 0.0 a 1.0
  final Widget? child;

  const FogShaderBackground({
    super.key,
    required this.intensity,
    this.child,
  });

  @override
  State<FogShaderBackground> createState() => _FogShaderBackgroundState();
}

class _FogShaderBackgroundState extends State<FogShaderBackground>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  Ticker? _ticker;
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker?.start();
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset(AppConstants.shaderFogPath);
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
      }
    } catch (e) {
      debugPrint(
          'FogShaderBackground: Usando fallback de gradiente dinâmico: $e');
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: widget.intensity),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, animatedIntensity, child) {
        return CustomPaint(
          painter: FogShaderPainter(
            shader: _shader,
            time: _elapsedSeconds,
            intensity: animatedIntensity,
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
