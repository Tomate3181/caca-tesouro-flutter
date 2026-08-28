/// Modelo para representar as coordenadas e status do Tesouro
class TreasureTarget {
  final double latitude;
  final double longitude;
  final String name;
  final DateTime createdAt;

  const TreasureTarget({
    required this.latitude,
    required this.longitude,
    this.name = 'Baú Ancestral',
    required this.createdAt,
  });

  TreasureTarget copyWith({
    double? latitude,
    double? longitude,
    String? name,
    DateTime? createdAt,
  }) {
    return TreasureTarget(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'TreasureTarget(name: $name, lat: ${latitude.toStringAsFixed(5)}, lon: ${longitude.toStringAsFixed(5)})';
}
