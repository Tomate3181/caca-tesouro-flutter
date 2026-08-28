import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Enumeração dos estados térmicos de proximidade do tesouro
enum ProximityState {
  cold,     // >= 50 passos (>= 40.0 m)
  warm,     // < 50 passos (< 40.0 m)
  hot,      // < 25 passos (< 20.0 m)
  veryHot,  // < 10 passos (< 8.0 m)
}

extension ProximityStateX on ProximityState {
  /// Nome de exibição do estado
  String get title {
    switch (this) {
      case ProximityState.cold:
        return 'FRIO';
      case ProximityState.warm:
        return 'MORNO';
      case ProximityState.hot:
        return 'QUENTE';
      case ProximityState.veryHot:
        return 'MUITO QUENTE';
    }
  }

  /// Dica textual de proximidade conforme a tabela do DESIGN_SYSTEM.md
  String get hintText {
    switch (this) {
      case ProximityState.cold:
        return 'Frio! Está longe do tesouro.';
      case ProximityState.warm:
        return 'Morno! Continue procurando.';
      case ProximityState.hot:
        return 'Quente! Está perto!';
      case ProximityState.veryHot:
        return 'Muito quente! Está quase lá!';
    }
  }

  /// Cor de destaque do estado
  Color get color {
    switch (this) {
      case ProximityState.cold:
        return AppConstants.colorCold;
      case ProximityState.warm:
        return AppConstants.colorWarm;
      case ProximityState.hot:
        return AppConstants.colorHot;
      case ProximityState.veryHot:
        return AppConstants.colorVeryHot;
    }
  }

  /// Intensidade passada para o Fragment Shader GLSL
  double get shaderIntensity {
    switch (this) {
      case ProximityState.cold:
        return 0.0;
      case ProximityState.warm:
        return 0.35;
      case ProximityState.hot:
        return 0.70;
      case ProximityState.veryHot:
        return 1.0;
    }
  }

  /// Indica se a Realidade Aumentada (AR) está desbloqueada (< 10 passos)
  bool get canOpenAR => this == ProximityState.veryHot;

  /// Indica se o Radar Tátil (feedback háptico) deve pulsar (< 25 passos)
  bool get isTactileRadarActive =>
      this == ProximityState.hot || this == ProximityState.veryHot;

  /// Ícone representativo do estado
  IconData get icon {
    switch (this) {
      case ProximityState.cold:
        return Icons.ac_unit_rounded;
      case ProximityState.warm:
        return Icons.wb_sunny_outlined;
      case ProximityState.hot:
        return Icons.local_fire_department_outlined;
      case ProximityState.veryHot:
        return Icons.whatshot_rounded;
    }
  }

  /// Cria o estado de proximidade a partir da contagem de passos restantes
  static ProximityState fromSteps(double steps) {
    if (steps < AppConstants.stepsThresholdHot) {
      return ProximityState.veryHot; // < 10 passos
    } else if (steps < AppConstants.stepsThresholdWarm) {
      return ProximityState.hot; // < 25 passos
    } else if (steps < AppConstants.stepsThresholdCold) {
      return ProximityState.warm; // < 50 passos
    } else {
      return ProximityState.cold; // >= 50 passos
    }
  }

  /// Cria o estado a partir da distância em metros
  static ProximityState fromDistanceMeters(double distanceMeters) {
    final steps = distanceMeters / AppConstants.metersPerStep;
    return fromSteps(steps);
  }
}
