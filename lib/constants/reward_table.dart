import '../models/celestial_body.dart';

const rewardTable = {
  15: {
    "coin": 10,
    "type": CelestialType.star,
  },
  30: {
    "coin": 30,
    "type": CelestialType.blueStar,
  },
  45: {
    "coin": 60,
    "type": CelestialType.shootingStar,
  },
  60: {
    "coin": 100,
    "type": CelestialType.mars,
  },
  120: {
    "coin": 250,
    "type": CelestialType.jupiter,
  },
  240: {
    "coin": 600,
    "type": CelestialType.galaxy,
  },
};