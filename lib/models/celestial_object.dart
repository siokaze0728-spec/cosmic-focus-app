class CelestialObject {
  final String type;
  final double x;
  final double y;
  final double size;
  final double rotation;

  CelestialObject({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
  });

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "x": x,
      "y": y,
      "size": size,
      "rotation": rotation,
    };
  }

  factory CelestialObject.fromMap(Map map) {
    return CelestialObject(
      type: map["type"],
      x: map["x"],
      y: map["y"],
      size: map["size"],
      rotation: map["rotation"],
    );
  }

  CelestialObject copyWith({
    String? type,
    double? x,
    double? y,
    double? size,
    double? rotation,
  }) {
    return CelestialObject(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }
}