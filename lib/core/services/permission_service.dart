import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Serviço para checagem e requisição de permissões
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Solicita todas as permissões necessárias para o jogo
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.activityRecognition,
    ];

    try {
      final statuses = await permissions.request();
      return statuses;
    } catch (e) {
      debugPrint('PermissionService: Erro ao solicitar permissões: $e');
      return {};
    }
  }

  /// Verifica se as permissões fundamentais foram concedidas
  Future<bool> hasRequiredPermissions() async {
    try {
      final locationStatus = await Permission.locationWhenInUse.status;
      return locationStatus.isGranted;
    } catch (_) {
      return false;
    }
  }
}
