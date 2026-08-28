import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../controllers/hunt_controller.dart';
import '../core/constants/app_constants.dart';

/// Tela de Realidade Aumentada para Abertura do Baú (Seção 5 do DESIGN_SYSTEM.md)
class ARTreasureScreen extends StatefulWidget {
  final HuntController? huntController;

  const ARTreasureScreen({super.key, this.huntController});

  @override
  State<ARTreasureScreen> createState() => _ARTreasureScreenState();
}

class _ARTreasureScreenState extends State<ARTreasureScreen>
    with SingleTickerProviderStateMixin {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARNode? chestNode;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isChestOpened = false;
  bool _arPluginAvailable = true;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    sessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
    );
    objectManager.onInitialize();

    // Detecta toque no Baú 3D no ambiente
    arObjectManager?.onNodeTap = (nodes) {
      if (nodes.contains(chestNode?.name)) {
        _triggerVictory();
      }
    };

    _spawnChest();
  }

  Future<void> _spawnChest() async {
    try {
      var newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: AppConstants.modelChestPath,
        scale: vector.Vector3(0.4, 0.4, 0.4),
        position: vector.Vector3(0.0, -0.4, -0.8), // 80cm à frente no chão
      );

      bool? added = await arObjectManager?.addNode(newNode);
      if (added == true) {
        chestNode = newNode;
      }
    } catch (e) {
      debugPrint('ARTreasureScreen: Erro ao instanciar ARNode: $e');
      setState(() {
        _arPluginAvailable = false;
      });
    }
  }

  Future<void> _triggerVictory() async {
    if (_isChestOpened) return;
    setState(() {
      _isChestOpened = true;
    });

    // Notifica o HuntController se fornecido
    if (widget.huntController != null) {
      await widget.huntController!.onTreasureFound();
    } else {
      // Toca áudio de vitória exigido
      try {
        await _audioPlayer.play(AssetSource(AppConstants.audioVictoryPath));
      } catch (_) {}
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppConstants.colorCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppConstants.colorGold, width: 2),
        ),
        title: const Row(
          children: [
            Text("🏆", style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text(
              "PARABÉNS!",
              style: TextStyle(
                color: AppConstants.colorGold,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Você encontrou o tesouro lendário!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow("🎯 Caça Concluída", "Sucesso"),
                  const SizedBox(height: 6),
                  _buildStatRow(
                    "👟 Passos na Sessão",
                    "${widget.huntController?.sessionSteps ?? 0} passos",
                  ),
                  const SizedBox(height: 6),
                  _buildStatRow(
                    "👑 Tesouros Coletados",
                    "${widget.huntController?.treasuresFound ?? 1}",
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.colorGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context); // Fecha o Dialog
              Navigator.pop(context); // Retorna para a tela principal
            },
            child: const Text(
              "COLETAR RECOMPENSA",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: AppConstants.colorAccent,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    _audioPlayer.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.colorDarkBg,
      appBar: AppBar(
        backgroundColor: AppConstants.colorCardBg,
        title: const Text(
          "Procure o Baú no Chão!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camada AR nativa (ARCore / ARKit)
          if (_arPluginAvailable)
            ARView(onARViewCreated: onARViewCreated)
          else
            _buildFallbackCameraSimulation(),

          // Overlay com instruções e Baú Interativo de Toque
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppConstants.colorGold.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppConstants.colorGold),
                      SizedBox(width: 8),
                      Text(
                        "Toque no Baú para abrir!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Botão de Toque Direto no Baú
                GestureDetector(
                  onTap: _triggerVictory,
                  child: AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.colorGold.withValues(alpha: 0.2),
                          border: Border.all(
                            color: AppConstants.colorGold,
                            width: 2 + math.sin(_sparkleController.value * 2 * math.pi),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.colorGold.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          size: 48,
                          color: AppConstants.colorGold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visão simulada com gradiente e baú estilizado caso ARCore não esteja disponível no ambiente
  Widget _buildFallbackCameraSimulation() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF050B14)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              size: 110,
              color: AppConstants.colorGold,
            ),
            const SizedBox(height: 16),
            Text(
              _isChestOpened ? "Baú Aberto!" : "Baú Lendário Detectado!",
              style: const TextStyle(
                color: AppConstants.colorGold,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
