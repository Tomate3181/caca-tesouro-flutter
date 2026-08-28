import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import '../core/constants/app_constants.dart';
import '../core/services/audio_service.dart';
import '../core/services/haptic_service.dart';
import '../models/proximity_state.dart';
import 'navigation_controller.dart';

/// Controlador central da Caça ao Tesouro (State Management)
class HuntController extends ChangeNotifier {
  final NavigationController navigation = NavigationController();
  final HapticService _hapticService = HapticService();
  final AudioService _audioService = AudioService();

  // Streams e assinaturas dos sensores
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSub;

  // Estado atual do jogador
  Position? _currentPosition;
  double _deviceHeading = 0.0; // Azimute da bússola em graus (0 a 360)
  int _initialPedometerSteps = -1;
  int _sessionSteps = 0;
  String _pedestrianStatus = 'Parado';

  // Modo Simulação (para testes rápidos de bancada / emuladores)
  bool _isSimulationMode = false;
  double _simulatedDistanceMeters = 55.0; // Inicia em "Frio" (55m / ~68 passos)
  double _simulatedHeading = 0.0;

  // Tesouros encontrados e status de vitória
  int _treasuresFound = 0;
  bool _isChestOpened = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  double get deviceHeading => _isSimulationMode ? _simulatedHeading : _deviceHeading;
  int get sessionSteps => _sessionSteps;
  String get pedestrianStatus => _pedestrianStatus;
  bool get isSimulationMode => _isSimulationMode;
  int get treasuresFound => _treasuresFound;
  bool get isChestOpened => _isChestOpened;

  /// Distância atual em metros até o tesouro
  double get currentDistanceMeters {
    if (_isSimulationMode) {
      return _simulatedDistanceMeters;
    }
    if (_currentPosition == null) {
      return 60.0; // Padrão se ainda não obteve GPS
    }
    return navigation.calculateDistance(_currentPosition!);
  }

  /// Passos restantes até o tesouro (1 passo = 0.8 metros)
  double get remainingSteps {
    return navigation.calculateStepsFromDistance(currentDistanceMeters);
  }

  /// Ângulo do azimute (Bearing) em graus até o tesouro
  double get currentBearing {
    if (_isSimulationMode) {
      return 45.0; // Bearing fixo de referência na simulação
    }
    if (_currentPosition == null) {
      return 0.0;
    }
    return navigation.calculateBearing(_currentPosition!);
  }

  /// Ângulo relativo que a Bússola 3D deve apontar (Bearing - Heading)
  double get compassTargetAngle {
    return navigation.calculateCompassTargetAngle(currentBearing, deviceHeading);
  }

  /// Estado de proximidade atual (Frio, Morno, Quente, Muito Quente)
  ProximityState get proximityState {
    return ProximityStateX.fromSteps(remainingSteps);
  }

  /// Intensidade do Shader GLSL baseada no estado
  double get shaderIntensity {
    return proximityState.shaderIntensity;
  }

  /// Indica se o botão de AR está liberado (< 10 passos)
  bool get canOpenAR {
    return proximityState.canOpenAR;
  }

  /// Inicia os sensores reais do dispositivo
  Future<void> initializeSensors() async {
    await _startLocationTracking();
    _startCompassTracking();
    _startPedometerTracking();
  }

  Future<void> _startLocationTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('HuntController: Serviço de localização desabilitado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Posição inicial rápida
        try {
          _currentPosition = await Geolocator.getLastKnownPosition();
          notifyListeners();
        } catch (_) {}

        // Stream de posição em tempo real
        _positionSub?.cancel();
        _positionSub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 1, // Atualiza a cada 1 metro
          ),
        ).listen((pos) {
          _currentPosition = pos;
          _updateTactileRadar();
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('HuntController: Erro ao iniciar GPS: $e');
    }
  }

  void _startCompassTracking() {
    try {
      _compassSub?.cancel();
      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading != null && !_isSimulationMode) {
          _deviceHeading = event.heading!;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('HuntController: Erro ao iniciar Bússola: $e');
    }
  }

  void _startPedometerTracking() {
    try {
      _stepCountSub?.cancel();
      _stepCountSub = Pedometer.stepCountStream.listen((StepCount event) {
        if (_initialPedometerSteps == -1) {
          _initialPedometerSteps = event.steps;
        }
        _sessionSteps = event.steps - _initialPedometerSteps;
        notifyListeners();
      }, onError: (error) {
        debugPrint('HuntController: Erro no Pedometer: $error');
      });

      _pedestrianStatusSub?.cancel();
      _pedestrianStatusSub = Pedometer.pedestrianStatusStream.listen((PedestrianStatus event) {
        _pedestrianStatus = event.status == 'walking'
            ? 'Caminhando'
            : (event.status == 'stopped' ? 'Parado' : event.status);
        notifyListeners();
      }, onError: (_) {});
    } catch (e) {
      debugPrint('HuntController: Pedômetro não suportado neste aparelho: $e');
    }
  }

  void _updateTactileRadar() {
    if (!_isChestOpened) {
      _hapticService.startRadarPulse(proximityState, currentDistanceMeters);
    }
  }

  // ==========================================
  // CONTROLES DE SIMULAÇÃO E TESTE
  // ==========================================

  void toggleSimulationMode(bool enabled) {
    _isSimulationMode = enabled;
    _updateTactileRadar();
    notifyListeners();
  }

  void setSimulatedDistance(double distanceMeters) {
    _simulatedDistanceMeters = distanceMeters.clamp(1.0, 100.0);
    _updateTactileRadar();
    notifyListeners();
  }

  void setSimulatedSteps(double steps) {
    setSimulatedDistance(steps * AppConstants.metersPerStep);
  }

  void setSimulatedHeading(double degrees) {
    _simulatedHeading = degrees % 360.0;
    notifyListeners();
  }

  /// Gera um novo tesouro aleatório a no máximo 60m
  void generateNewTreasure() {
    _isChestOpened = false;
    if (_currentPosition != null && !_isSimulationMode) {
      navigation.generateRandomTreasure(_currentPosition!);
    } else {
      // Simulação: escolhe uma nova distância aleatória até 60m
      navigation.generateRandomTreasureFromCoords(
        AppConstants.initialTreasureLat,
        AppConstants.initialTreasureLon,
      );
      _simulatedDistanceMeters = 50.0;
    }
    _updateTactileRadar();
    notifyListeners();
  }

  /// Restaura as coordenadas para o ponto inicial exigido pela especificação
  void resetToInitialTreasure() {
    _isChestOpened = false;
    navigation.resetToInitialTreasure();
    _simulatedDistanceMeters = 55.0;
    _updateTactileRadar();
    notifyListeners();
  }

  /// Disparado quando o jogador toca no baú na tela de Realidade Aumentada (AR)
  Future<void> onTreasureFound() async {
    if (_isChestOpened) return;
    _isChestOpened = true;
    _treasuresFound++;

    // Toca som de vitória
    await _audioService.playVictorySound();

    // Vibração comemorativa
    await _hapticService.triggerVictoryPattern();

    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _compassSub?.cancel();
    _stepCountSub?.cancel();
    _pedestrianStatusSub?.cancel();
    _hapticService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
