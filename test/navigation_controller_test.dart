import 'package:flutter_test/flutter_test.dart';
import 'package:caca_tesouro_flutter/controllers/navigation_controller.dart';
import 'package:caca_tesouro_flutter/core/constants/app_constants.dart';
import 'package:caca_tesouro_flutter/models/proximity_state.dart';

void main() {
  group('NavigationController & Business Logic Tests', () {
    late NavigationController navigation;

    setUp(() {
      navigation = NavigationController();
    });

    test('1. Initial treasure coordinates match DESIGN_SYSTEM.md specification', () {
      expect(navigation.treasureLat, equals(-23.11443));
      expect(navigation.treasureLon, equals(-45.70780));
    });

    test('2. Step conversion formula: 1 step = 0.8 meters', () {
      expect(navigation.calculateStepsFromDistance(0.8), equals(1.0));
      expect(navigation.calculateStepsFromDistance(40.0), equals(50.0));
      expect(navigation.calculateStepsFromDistance(20.0), equals(25.0));
      expect(navigation.calculateStepsFromDistance(8.0), equals(10.0));
      expect(navigation.calculateStepsFromDistance(4.0), equals(5.0));
    });

    test('3. ProximityState mapping adheres to the specification table', () {
      // >= 50 steps -> Frio (Cold)
      expect(ProximityStateX.fromSteps(60.0), equals(ProximityState.cold));
      expect(ProximityStateX.fromSteps(50.0), equals(ProximityState.cold));
      expect(ProximityState.cold.shaderIntensity, equals(0.0));
      expect(ProximityState.cold.canOpenAR, isFalse);

      // < 50 steps -> Morno (Warm)
      expect(ProximityStateX.fromSteps(49.9), equals(ProximityState.warm));
      expect(ProximityStateX.fromSteps(25.0), equals(ProximityState.warm));
      expect(ProximityState.warm.shaderIntensity, equals(0.35));
      expect(ProximityState.warm.canOpenAR, isFalse);

      // < 25 steps -> Quente (Hot)
      expect(ProximityStateX.fromSteps(24.9), equals(ProximityState.hot));
      expect(ProximityStateX.fromSteps(10.0), equals(ProximityState.hot));
      expect(ProximityState.hot.shaderIntensity, equals(0.70));
      expect(ProximityState.hot.isTactileRadarActive, isTrue);
      expect(ProximityState.hot.canOpenAR, isFalse);

      // < 10 steps -> Muito Quente (Very Hot)
      expect(ProximityStateX.fromSteps(9.9), equals(ProximityState.veryHot));
      expect(ProximityStateX.fromSteps(2.0), equals(ProximityState.veryHot));
      expect(ProximityState.veryHot.shaderIntensity, equals(1.0));
      expect(ProximityState.veryHot.isTactileRadarActive, isTrue);
      expect(ProximityState.veryHot.canOpenAR, isTrue);
    });

    test('4. Compass target angle normalization (Bearing - Heading)', () {
      // Device facing north (0), bearing 90 (East) -> Needle points 90
      expect(navigation.calculateCompassTargetAngle(90.0, 0.0), equals(90.0));

      // Device facing east (90), bearing 90 (East) -> Needle points straight ahead (0)
      expect(navigation.calculateCompassTargetAngle(90.0, 90.0), equals(0.0));

      // Wrap around test: bearing 10, heading 350 -> +20
      expect(navigation.calculateCompassTargetAngle(10.0, 350.0), equals(20.0));

      // Wrap around test: bearing 350, heading 10 -> -20
      expect(navigation.calculateCompassTargetAngle(350.0, 10.0), equals(-20.0));
    });

    test('5. Random treasure generator creates coordinates within max 60 meters', () {
      const originLat = -23.11443;
      const originLon = -45.70780;

      for (int i = 0; i < 20; i++) {
        navigation.generateRandomTreasureFromCoords(
          originLat,
          originLon,
          maxDistanceMeters: AppConstants.maxRandomRadiusMeters,
        );

        final distance = navigation.calculateDistanceBetween(
          originLat,
          originLon,
          navigation.treasureLat,
          navigation.treasureLon,
        );

        expect(distance, lessThanOrEqualTo(60.1));
        expect(distance, greaterThanOrEqualTo(9.9));
      }
    });

    test('6. ResetToInitialTreasure restores exact default coordinates', () {
      navigation.generateRandomTreasureFromCoords(0.0, 0.0);
      expect(navigation.treasureLat, isNot(equals(AppConstants.initialTreasureLat)));

      navigation.resetToInitialTreasure();
      expect(navigation.treasureLat, equals(AppConstants.initialTreasureLat));
      expect(navigation.treasureLon, equals(AppConstants.initialTreasureLon));
    });
  });
}
