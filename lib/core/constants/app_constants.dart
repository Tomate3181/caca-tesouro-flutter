import 'package:flutter/material.dart';

/// Constantes globais do aplicativo de Caça ao Tesouro
class AppConstants {
  // Posição inicial exigida pela especificação
  static const double initialTreasureLat = -23.11443;
  static const double initialTreasureLon = -45.70780;

  // Regra de conversão: 1 passo = 0.8 metros
  static const double metersPerStep = 0.8;

  // Raio máximo para geração de novos tesouros aleatórios
  static const double maxRandomRadiusMeters = 60.0;

  // Limiares de passos para mudança de estado
  static const double stepsThresholdCold = 50.0; // >= 50 passos (>= 40m)
  static const double stepsThresholdWarm = 25.0; // < 50 passos (< 40m)
  static const double stepsThresholdHot = 10.0;  // < 25 passos (< 20m)
  // < 10 passos (< 8m) -> Muito Quente (Libera AR)

  // Distâncias em metros correspondentes
  static const double distanceColdMeters = 40.0;
  static const double distanceWarmMeters = 20.0;
  static const double distanceHotMeters = 8.0;

  // Cores do Design System
  static const Color colorCold = Color(0xFF87CEFA);     // Azul Claro (#87CEFA)
  static const Color colorWarm = Color(0xFFFF8C00);     // Laranja Escuro (#FF8C00)
  static const Color colorHot = Color(0xFFFF4500);      // Laranja Avermelhado (#FF4500)
  static const Color colorVeryHot = Color(0xFFFF2200);  // Vermelho Intenso (#FF2200)
  
  static const Color colorGold = Color(0xFFFFD700);     // Dourado para tesouros
  static const Color colorDarkBg = Color(0xFF0D1322);   // Fundo principal escuro
  static const Color colorCardBg = Color(0xFF162035);   // Fundo de cards com glassmorphism
  static const Color colorAccent = Color(0xFF00E5FF);   // Ciano moderno de destaque

  // Caminhos de Assets
  static const String shaderFogPath = 'assets/shaders/fog_effect.frag';
  // Compass is now rendered via CustomPainter — no external model needed
  static const String modelChestPath = 'assets/models/treasure_chest.gltf';
  static const String audioVictoryPath = 'audio/victory.mp3';
}
