enum CelestialType {
  star,
  blueStar,
  shootingStar,
  mars,
  jupiter,
  galaxy,
}

class CelestialBody {

  String id;

  CelestialType type;

  double x;

  double y;

  CelestialBody({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
  });
}