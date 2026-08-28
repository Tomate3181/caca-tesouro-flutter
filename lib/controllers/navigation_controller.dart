import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

/// Controlador responsável pelos cálculos matemáticos de GPS, Distância, Passos e Bússola
class NavigationController {
  // Posição fixa inicial exigida
  double treasureLat = AppConstants.initialTreasureLat;
  double treasureLon = AppConstants.initialTreasureLon;

  /// Calcula a distância em metros a partir de um objeto Position
  double calculateDistance(Position userPosition) {
    return calculateDistanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      treasureLat,
      treasureLon,
    );
  }

  /// Calcula a distância em metros a partir de coordenadas explícitas
  double calculateDistanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }

  /// Calcula a distância em passos (1 passo = 0.8 metros)
  double calculateSteps(Position userPosition) {
    final distanceInMeters = calculateDistance(userPosition);
    return calculateStepsFromDistance(distanceInMeters);
  }

  /// Converte qualquer distância em metros para quantidade de passos
  double calculateStepsFromDistance(double distanceInMeters) {
    return distanceInMeters / AppConstants.metersPerStep;
  }

  /// Calcula o ângulo de azimute (bearing) em graus (-180 a 180) até o tesouro
  double calculateBearing(Position userPosition) {
    return calculateBearingBetween(
      userPosition.latitude,
      userPosition.longitude,
      treasureLat,
      treasureLon,
    );
  }

  /// Calcula o bearing em graus entre dois pontos
  double calculateBearingBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.bearingBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }

  /// Calcula o ângulo relativo para a bússola apontar diretamente ao tesouro:
  /// Ângulo da Bússola = BearingToTreasure - DeviceHeading
  double calculateCompassTargetAngle(double bearing, double deviceHeading) {
    double angle = bearing - deviceHeading;
    // Normaliza entre -180 e 180 graus
    while (angle > 180.0) {
      angle -= 360.0;
    }
    while (angle < -180.0) {
      angle += 360.0;
    }
    return angle;
  }

  /// Gera um novo tesouro aleatório a no máximo 60 metros da posição atual
  void generateRandomTreasure(Position currentPosition) {
    generateRandomTreasureFromCoords(
      currentPosition.latitude,
      currentPosition.longitude,
      maxDistanceMeters: AppConstants.maxRandomRadiusMeters,
    );
  }

  /// Gera um novo tesouro em coordenadas aleatórias dentro de um raio de metros
  void generateRandomTreasureFromCoords(
    double currentLat,
    double currentLon, {
    double maxDistanceMeters = 60.0,
  }) {
    // Gera distância aleatória entre 10m e maxDistanceMeters
    final random = math.Random();
    final double distance = 10.0 + random.nextDouble() * (maxDistanceMeters - 10.0);
    // Gera ângulo aleatório de 0 a 2*pi radianos
    final double angleRad = random.nextDouble() * 2 * math.pi;

    // Conversão geodésica aproximada:
    // 1 grau de latitude = ~111.139 metros
    // 1 grau de longitude = ~111.139 * cos(lat) metros
    const double metersPerDegreeLat = 111139.0;
    final double latRad = currentLat * (math.pi / 180.0);
    final double metersPerDegreeLon = 111139.0 * math.cos(latRad);

    final double deltaLat = (distance * math.cos(angleRad)) / metersPerDegreeLat;
    final double deltaLon = (distance * math.sin(angleRad)) / metersPerDegreeLon;

    treasureLat = currentLat + deltaLat;
    treasureLon = currentLon + deltaLon;
  }

  /// Restaura as coordenadas para o ponto inicial exigido pela especificação
  void resetToInitialTreasure() {
    treasureLat = AppConstants.initialTreasureLat;
    treasureLon = AppConstants.initialTreasureLon;
  }
}
