import 'package:flutter_test/flutter_test.dart';
import 'package:caca_tesouro_flutter/main.dart';
import 'package:caca_tesouro_flutter/views/home_hunt_screen.dart';
import 'package:caca_tesouro_flutter/views/widgets/distance_indicator.dart';
import 'package:caca_tesouro_flutter/views/widgets/proximity_badge.dart';

void main() {
  testWidgets(
      'App renders HomeHuntScreen with Proximity Badge and Distance Indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TreasureHuntApp());
    await tester.pump();

    // Verifica se a tela principal foi instanciada
    expect(find.byType(HomeHuntScreen), findsOneWidget);
    expect(find.text('CAÇA AO TESOURO'), findsOneWidget);

    // Verifica se o Badge de Proximidade e o Card de Distância são exibidos
    expect(find.byType(ProximityBadge), findsOneWidget);
    expect(find.byType(DistanceIndicator), findsOneWidget);

    // Verifica presença dos rótulos de métricas
    expect(find.text('PASSOS RESTANTES'), findsOneWidget);
    expect(find.text('DISTÂNCIA'), findsOneWidget);
    expect(find.text('PASSOS DADOS'), findsOneWidget);
  });
}
