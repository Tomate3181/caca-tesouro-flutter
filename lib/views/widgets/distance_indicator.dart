import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/proximity_state.dart';

/// Card de exibição da distância, passos e dica de proximidade
class DistanceIndicator extends StatelessWidget {
  final double steps;
  final double distanceMeters;
  final ProximityState state;
  final int sessionSteps;
  final String pedestrianStatus;

  const DistanceIndicator({
    super.key,
    required this.steps,
    required this.distanceMeters,
    required this.state,
    required this.sessionSteps,
    required this.pedestrianStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.colorCardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: state.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dica de proximidade destacada
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              state.hintText,
              key: ValueKey(state.hintText),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: state.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Métricas em linha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Passos restantes até o tesouro
              _buildMetricColumn(
                icon: Icons.directions_walk_rounded,
                value: steps.toStringAsFixed(1),
                label: 'PASSOS RESTANTES',
                valueColor: Colors.white,
                accentColor: state.color,
              ),
              Container(width: 1, height: 45, color: Colors.white12),
              // Distância em metros
              _buildMetricColumn(
                icon: Icons.place_rounded,
                value: '${distanceMeters.toStringAsFixed(1)}m',
                label: 'DISTÂNCIA',
                valueColor: Colors.white,
                accentColor: AppConstants.colorAccent,
              ),
              Container(width: 1, height: 45, color: Colors.white12),
              // Passos reais caminhados na sessão (Pedômetro)
              _buildMetricColumn(
                icon: Icons.trending_up_rounded,
                value: '$sessionSteps',
                label: 'PASSOS DADOS',
                valueColor: Colors.white,
                accentColor: AppConstants.colorGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color valueColor,
    required Color accentColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
