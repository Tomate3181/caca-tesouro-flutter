import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Serviço para gerenciar a reprodução de efeitos sonoros
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  /// Toca o áudio de vitória do tesouro
  Future<void> playVictorySound() async {
    try {
      final p = player;
      await p.stop();
      await p.setSource(AssetSource(AppConstants.audioVictoryPath));
      await p.resume();
    } catch (e) {
      debugPrint('AudioService: Erro ao tocar som de vitória: $e');
    }
  }

  /// Para qualquer reprodução em andamento
  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('AudioService: Erro ao parar áudio: $e');
    }
  }

  /// Libera os recursos do reprodutor
  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
