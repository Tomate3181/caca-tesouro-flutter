import 'package:flutter/material.dart';
import '../controllers/hunt_controller.dart';
import '../core/constants/app_constants.dart';
import '../core/services/permission_service.dart';
import '../core/shaders/shader_controller.dart';
import '../models/proximity_state.dart';
import 'ar_treasure_screen.dart';
import 'compass_3d_view.dart';
import 'widgets/distance_indicator.dart';
import 'widgets/proximity_badge.dart';
import 'widgets/simulation_drawer.dart';
import 'widgets/tactile_radar_widget.dart';

/// Tela Principal da Caça ao Tesouro (Dashboard completo)
class HomeHuntScreen extends StatefulWidget {
  const HomeHuntScreen({super.key});

  @override
  State<HomeHuntScreen> createState() => _HomeHuntScreenState();
}

class _HomeHuntScreenState extends State<HomeHuntScreen> {
  late final HuntController _huntController;
  final PermissionService _permissionService = PermissionService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _huntController = HuntController();
    _initApp();
  }

  Future<void> _initApp() async {
    await _permissionService.requestAllPermissions();
    await _huntController.initializeSensors();
  }

  @override
  void dispose() {
    _huntController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _huntController,
      builder: (context, _) {
        final proximity = _huntController.proximityState;
        final canOpenAR = _huntController.canOpenAR;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppConstants.colorDarkBg,
          endDrawer: SimulationDrawer(controller: _huntController),
          body: FogShaderBackground(
            intensity: _huntController.shaderIntensity,
            child: SafeArea(
              child: Column(
                children: [
                  // Barra Superior
                  _buildTopBar(proximity),

                  // Área Central Rolável
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),

                          // Badge de Proximidade (FRIO, MORNO, QUENTE, MUITO QUENTE)
                          ProximityBadge(state: proximity),

                          const SizedBox(height: 20),

                          // Bússola 3D envolta com Radar Tátil
                          TactileRadarWidget(
                            state: proximity,
                            child: Compass3DView(
                              targetAngleDegrees: _huntController.compassTargetAngle,
                              glowColor: proximity.color,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Painel de Distância, Passos e Dica
                          DistanceIndicator(
                            steps: _huntController.remainingSteps,
                            distanceMeters: _huntController.currentDistanceMeters,
                            state: proximity,
                            sessionSteps: _huntController.sessionSteps,
                            pedestrianStatus: _huntController.pedestrianStatus,
                          ),

                          const SizedBox(height: 24),

                          // Botão do Modo AR (Liberado quando < 10 passos)
                          _buildARButton(canOpenAR, proximity),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ProximityState proximity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título e Ícone do Tesouro
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.colorGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.colorGold.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: AppConstants.colorGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAÇA AO TESOURO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'AR & BÚSSOLA 3D',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Botões de Ação Superior (Trofus e Simulador)
          Row(
            children: [
              // Contador de Tesouros Coletados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.colorGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: AppConstants.colorGold, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_huntController.treasuresFound}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Botão para abrir o Drawer de Simulação / Teste
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppConstants.colorCardBg,
                  foregroundColor: _huntController.isSimulationMode
                      ? AppConstants.colorAccent
                      : Colors.white70,
                ),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Simulador / Testes',
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildARButton(bool canOpenAR, ProximityState proximity) {
    if (canOpenAR) {
      // Botão Liberado e Brilhante (< 10 passos)
      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppConstants.colorGold, Color(0xFFFF8C00)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.colorGold.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ARTreasureScreen(huntController: _huntController),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_in_ar_rounded, color: Colors.black, size: 28),
              SizedBox(width: 12),
              Text(
                'ABRIR MODO AR (ENCONTRAR BAÚ)',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Botão Bloqueado (>= 10 passos)
      return Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.white38, size: 20),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Modo AR bloqueado (Aproxime-se a menos de 10 passos)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
