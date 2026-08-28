import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../models/proximity_state.dart';

/// Serviço responsável pelo Radar Tátil (feedback háptico por vibração)
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  Timer? _radarTimer;
  bool _hasVibratorChecked = false;
  bool _canVibrate = true;

  Future<void> _checkVibrator() async {
    if (_hasVibratorChecked) return;
    try {
      final hasVibrator = await Vibration.hasVibrator();
      _canVibrate = hasVibrator ?? false;
      _hasVibratorChecked = true;
    } catch (_) {
      _canVibrate = false;
      _hasVibratorChecked = true;
    }
  }

  /// Inicia o pulso periódico do Radar Tátil de acordo com a proximidade
  void startRadarPulse(ProximityState state, double distanceMeters) {
    stopRadarPulse();
    if (!state.isTactileRadarActive) return;

    // Frequência do pulso: quanto mais perto, mais rápido o pulso
    // Muito quente (<8m): pulso a cada 400ms
    // Quente (8m-20m): pulso a cada 1000ms
    final int intervalMs = (state == ProximityState.veryHot)
        ? 450
        : (distanceMeters < 15.0 ? 700 : 1100);

    _radarTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      await _checkVibrator();
      if (_canVibrate) {
        try {
          if (state == ProximityState.veryHot) {
            Vibration.vibrate(duration: 120, amplitude: 255);
          } else {
            Vibration.vibrate(duration: 70, amplitude: 160);
          }
        } catch (_) {
          HapticFeedback.heavyImpact();
        }
      } else {
        HapticFeedback.mediumImpact();
      }
    });
  }

  /// Para o radar de vibração contínuo
  void stopRadarPulse() {
    _radarTimer?.cancel();
    _radarTimer = null;
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  /// Vibração especial comemorativa ao abrir o Baú do Tesouro
  Future<void> triggerVictoryPattern() async {
    stopRadarPulse();
    await _checkVibrator();
    if (_canVibrate) {
      try {
        // Padrão: Espera 0, Vibra 100, Espera 80, Vibra 100, Espera 80, Vibra 300
        await Vibration.vibrate(
          pattern: [0, 100, 80, 100, 80, 300],
          intensities: [0, 180, 0, 220, 0, 255],
        );
      } catch (_) {
        HapticFeedback.heavyImpact();
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void dispose() {
    stopRadarPulse();
  }
}
