import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_storage.dart';
import '../models/celestial_object.dart';

class UniverseScreen extends StatefulWidget {
  const UniverseScreen({super.key});

  @override
  State<UniverseScreen> createState() => _UniverseScreenState();
}

class _UniverseScreenState extends State<UniverseScreen>
    with SingleTickerProviderStateMixin {
  final random = Random();

  List<CelestialObject> objects = [];

  late AnimationController controller;

  final Stopwatch astronautDriftClock = Stopwatch();

  List<Offset> velocities = [];

  List<Offset> explosionVelocities = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );

    loadObjects();

    controller.addListener(() {
      moveObjects();
    });

    astronautDriftClock.start();

    controller.repeat();
  }

  void loadObjects() {
    objects = GameStorage.getObjects();

    velocities = List.generate(
      objects.length,
          (_) => Offset(
        (random.nextDouble() - 0.5) * 0.4,
        (random.nextDouble() - 0.5) * 0.4,
      ),
    );
  }

  void showAstronautInfo() {
    final totalMinutes = GameStorage.getTotalFocusMinutes();
    final rank = GameStorage.getRank();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("宇宙飛行士"),
        content: Text(
          "ランク：$rank\n総集中時間：$totalMinutes 分",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  double objectRotation(String type, int index) {
    final t = controller.value * 2 * pi;

    switch (type) {
      case "satellite":
        return t * 0.4;

      case "space_station":
        return t * 0.12;

      case "rocket":
        return -0.6;

      case "ufo":
        return sin(t * 3 + index) * 0.25;

      case "black_hole":
        return t * 1.2;

      case "space_whale":
        return sin(t * 0.08 + index) * 0.08;

      default:
        return 0;
    }
  }

  void prepareExplosion() {
    final screenCenterX = 180.0;
    final screenCenterY = 350.0;

    for (int i = 0; i < objects.length; i++) {
      objects[i] = objects[i].copyWith(
        x: screenCenterX,
        y: screenCenterY,
      );
    }

    explosionVelocities = List.generate(
      objects.length,
          (_) {
        final angle = random.nextDouble() * 2 * pi;
        final speed = 6 + random.nextDouble() * 8;

        return Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        );
      },
    );
  }

  void moveObjects() {
    if (!mounted) return;

    setState(() {
      final t = controller.value * 2 * pi;

      for (int i = 0; i < objects.length; i++) {
        final object = objects[i];

        double newX = object.x;
        double newY = object.y;

        switch (object.type) {
          case "satellite":
            newX = object.x + cos(t * 0.4 + i) * 0.8;
            newY = object.y + sin(t * 0.4 + i) * 0.8;
            break;

          case "space_station":
            newX = object.x + cos(t * 0.15 + i) * 0.4;
            newY = object.y + sin(t * 0.15 + i) * 0.4;
            break;

          case "rocket":
            newX = object.x + 0.5;
            newY = object.y - 0.35;
            break;

          case "probe":
            newX = object.x;
            newY = object.y;
            break;

          case "ufo":
            newX = object.x +
                sin(t * 2.7 + i) * 1.4 +
                cos(t * 4.1 + i) * 0.9;
            newY = object.y +
                cos(t * 3.3 + i) * 1.2 +
                sin(t * 5.2 + i) * 0.8;
            break;

          case "black_hole":
            newX = object.x + cos(t * 0.35 + i) * 0.5;
            newY = object.y + sin(t * 0.25 + i) * 0.5;
            break;

          case "space_whale":
            newX = object.x + sin(t * 0.08 + i) * 0.18;
            newY = object.y + cos(t * 0.06 + i) * 0.12;
            break;

          default:
            newX = object.x + velocities[i].dx;
            newY = object.y + velocities[i].dy;
        }

        if (newX < 0 || newX > MediaQuery.of(context).size.width - 80) {
          velocities[i] = Offset(
            -velocities[i].dx,
            velocities[i].dy,
          );
          newX = object.x;
        }

        if (newY < 0 || newY > MediaQuery.of(context).size.height - 160) {
          velocities[i] = Offset(
            velocities[i].dx,
            -velocities[i].dy,
          );
          newY = object.y;
        }

        objects[i] = object.copyWith(
          x: newX,
          y: newY,
        );
      }
    });
  }

  void updateObjectPosition(
      int index,
      Offset delta,
      ) {
    setState(() {
      objects[index] = objects[index].copyWith(
        x: objects[index].x + delta.dx,
        y: objects[index].y + delta.dy,
      );
    });

    GameStorage.saveObjects(objects);
  }

  Widget buildSpaceObject(String type, int index) {

    switch (type) {
      case "satellite":
        return Image.asset(
          "assets/objects/satellite.png",
          width: 50,
          height: 50,
          filterQuality: FilterQuality.none,
        );

      case "rocket":
        return Image.asset(
          "assets/objects/rocket.png",
          width: 60,
          height: 60,
          filterQuality: FilterQuality.none,
        );

      case "space_station":
        return Image.asset(
          "assets/objects/space_station.png",
          width: 100,
          height: 100,
          filterQuality: FilterQuality.none,
        );

      case "probe":
        return Image.asset(
          "assets/objects/probe.png",
          width: 45,
          height: 45,
          filterQuality: FilterQuality.none,
        );

      case "small_star":
        return Image.asset(
          "assets/stars/star0.png",
          width: 30,
          height: 30,
          filterQuality: FilterQuality.none,
        );
      case "small_star_0":
      case "small_star_1":
      case "small_star_2":
      case "small_star_3":
      case "small_star_4":
      case "small_star_5":
      case "small_star_6":
      case "small_star_7":
      case "small_star_8":
      case "small_star_9":
        final number = type.split("_").last;

        return Image.asset(
          "assets/stars/star$number.png",
          width: 30,
          height: 30,
          filterQuality: FilterQuality.none,
        );
      case "blue_star":
        return Image.asset(
          "assets/objects/blue_star.png",
          width: 50,
          height: 50,
          filterQuality: FilterQuality.none,
        );

      case "shooting_star":
        return Image.asset(
          "assets/objects/shooting_star.png",
          width: 30,
          height: 30,
          filterQuality: FilterQuality.none,
        );

      case "mars":
        return Image.asset(
          "assets/objects/mars.png",
          width: 60,
          height: 60,
          filterQuality: FilterQuality.none,
        );

      case "jupiter":
        return Image.asset(
          "assets/objects/jupiter.png",
          width: 85,
          height: 85,
          filterQuality: FilterQuality.none,
        );

      case "galaxy":
        return Image.asset(
          "assets/objects/galaxy.png",
          width: 140,
          height: 140,
          filterQuality: FilterQuality.none,
        );

      case "ufo":
        return Image.asset(
          "assets/objects/ufo.png",
          width: 50,
          height: 50,
          filterQuality: FilterQuality.none,
        );

      case "black_hole":
        return Image.asset(
          "assets/objects/black_hole.png",
          width: 80,
          height: 80,
          filterQuality: FilterQuality.none,
        );

      case "space_whale":
        return Image.asset(
          "assets/objects/space_whale.png",
          width: 100,
          height: 100,
          filterQuality: FilterQuality.none,
        );
      default:
        return const Icon(Icons.star, color: Colors.yellow, size: 14);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    GameStorage.saveObjects(objects);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("自分の宇宙"),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            for (int i = 0; i < objects.length; i++)
              Positioned(
                left: objects[i].x,
                top: objects[i].y,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    updateObjectPosition(
                      i,
                      details.delta,
                    );
                  },
                  child: Transform.rotate(
                    angle: objects[i].rotation +
                        objectRotation(
                          objects[i].type,
                          i,
                        ),
                    child: Transform.scale(
                      scale: objects[i].size,
                      child: buildSpaceObject(
                        objects[i].type,
                        i,
                      ),
                    ),
                  ),
                ),
              ),

            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final screenSize = MediaQuery.of(context).size;
                final driftSeconds =
                    astronautDriftClock.elapsedMilliseconds / 1000.0;
                const astronautSize = 46.0;
                final maxX = max(0.0, screenSize.width - astronautSize - 12);
                final maxY = max(0.0, screenSize.height - astronautSize - 128);

                final normalizedX = 0.5 +
                    sin(driftSeconds * 0.13) * 0.28 +
                    sin(driftSeconds * 0.071 + 1.8) * 0.18 +
                    cos(driftSeconds * 0.047 + 0.6) * 0.12;
                final normalizedY = 0.5 +
                    cos(driftSeconds * 0.11 + 0.5) * 0.26 +
                    sin(driftSeconds * 0.061 + 2.4) * 0.2 +
                    cos(driftSeconds * 0.039) * 0.1;

                final x = (normalizedX.clamp(0.04, 0.96) * maxX).toDouble();
                final y = (normalizedY.clamp(0.04, 0.96) * maxY).toDouble();
                final angle = sin(driftSeconds * 0.19) * 0.18;

                return Positioned(
                  left: x,
                  top: y,
                  child: GestureDetector(
                    onTap: showAstronautInfo,
                    child: Transform.rotate(
                      angle: angle,
                      child: Image.asset(
                        "assets/objects/astronaut.png",
                        width: astronautSize,
                        height: astronautSize,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PixelStar extends StatelessWidget {
  final int seed;
  final double size;

  const PixelStar({
    super.key,
    required this.seed,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PixelStarPainter(seed),
    );
  }
}

class PixelStarPainter extends CustomPainter {
  final int seed;

  PixelStarPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint();

    const grid = 11;
    final cell = size.width / grid;

    final starPixels = [
      [0, 5],
      [1, 4], [1, 5], [1, 6],
      [2, 3], [2, 4], [2, 5], [2, 6], [2, 7],
      [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [3, 8],
      [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [4, 8], [4, 9],
      [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [5, 8], [5, 9], [5, 10],
      [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [6, 8], [6, 9],
      [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8],
      [8, 3], [8, 4], [8, 5], [8, 6], [8, 7],
      [9, 4], [9, 5], [9, 6],
      [10, 5],
    ];

    for (final pixel in starPixels) {
      final y = pixel[0];
      final x = pixel[1];

      final brightness = 180 + random.nextInt(75);

      paint.color = Color.fromARGB(
        255,
        255,
        brightness,
        80 + random.nextInt(80),
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x * cell,
          y * cell,
          cell,
          cell,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PixelStarPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
