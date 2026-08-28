import 'package:flutter/material.dart';
import '../../controllers/hunt_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/proximity_state.dart';

/// Painel de controle para simulação e teste prático de todos os estados
class SimulationDrawer extends StatelessWidget {
  final HuntController controller;

  const SimulationDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppConstants.colorDarkBg,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Cabeçalho do painel
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppConstants.colorAccent, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Simulador & Testes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ative o modo simulação para validar todos os estados de proximidade, shader e bússola sem precisar caminhar.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Switch de Modo Simulação
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.colorCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.isSimulationMode
                          ? AppConstants.colorAccent
                          : Colors.white12,
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Modo Simulação',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      controller.isSimulationMode
                          ? 'Usando controles manuais'
                          : 'Usando GPS e Sensores reais',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    value: controller.isSimulationMode,
                    activeColor: AppConstants.colorAccent,
                    onChanged: (val) => controller.toggleSimulationMode(val),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'ATALHOS DE ESTADO (TABELA)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Botões de atalho rápido para os 4 estados
                _buildQuickStateButton(
                  title: 'Frio (>= 50 passos)',
                  subtitle: '55.0 metros (~68 passos) | Intensity = 0.0',
                  color: AppConstants.colorCold,
                  onTap: () {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedDistance(55.0);
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickStateButton(
                  title: 'Morno (< 50 passos)',
                  subtitle: '30.0 metros (~37 passos) | Intensity = 0.35',
                  color: AppConstants.colorWarm,
                  onTap: () {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedDistance(30.0);
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickStateButton(
                  title: 'Quente (< 25 passos)',
                  subtitle: '15.0 metros (~18 passos) | Intensity = 0.70',
                  color: AppConstants.colorHot,
                  onTap: () {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedDistance(15.0);
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickStateButton(
                  title: 'Muito Quente (< 10 passos) [AR]',
                  subtitle: '5.0 metros (~6 passos) | Intensity = 1.0',
                  color: AppConstants.colorVeryHot,
                  onTap: () {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedDistance(5.0);
                  },
                ),

                const SizedBox(height: 24),
                const Text(
                  'AJUSTE FINO DE DISTÂNCIA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Slider de Distância
                Slider(
                  value: controller.currentDistanceMeters.clamp(1.0, 80.0),
                  min: 1.0,
                  max: 80.0,
                  divisions: 79,
                  activeColor: controller.proximityState.color,
                  label: '${controller.currentDistanceMeters.toStringAsFixed(1)}m',
                  onChanged: (val) {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedDistance(val);
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'GIRO DA BÚSSOLA (AZIMUTE)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Slider de Ângulo
                Slider(
                  value: controller.deviceHeading.clamp(0.0, 360.0),
                  min: 0.0,
                  max: 360.0,
                  divisions: 36,
                  activeColor: AppConstants.colorAccent,
                  label: '${controller.deviceHeading.toStringAsFixed(0)}°',
                  onChanged: (val) {
                    if (!controller.isSimulationMode) controller.toggleSimulationMode(true);
                    controller.setSimulatedHeading(val);
                  },
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),

                // Gerador de Tesouro Aleatório
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.colorCardBg,
                    foregroundColor: AppConstants.colorGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppConstants.colorGold, width: 1),
                    ),
                  ),
                  icon: const Icon(Icons.casino_rounded),
                  label: const Text(
                    'Gerar Tesouro Aleatório (<= 60m)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    controller.generateNewTreasure();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Novo tesouro gerado a no máximo 60m!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Reset para coordenadas iniciais
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restaurar Posição Inicial'),
                  onPressed: () {
                    controller.resetToInitialTreasure();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📍 Restaurado para Lat: -23.11443, Lon: -45.70780'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStateButton({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
