import 'package:flutter/material.dart';

import '../data/game_storage.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discovered = GameStorage.getObjects().map((e) => e.type).toSet();

    final allObjects = [
      "small_star_0",
      "small_star_1",
      "small_star_2",
      "small_star_3",
      "small_star_4",
      "small_star_5",
      "small_star_6",
      "small_star_7",
      "small_star_8",
      "small_star_9",
      "blue_star",
      "shooting_star",
      "mars",
      "jupiter",
      "galaxy",
      "satellite",
      "rocket",
      "space_station",
      "probe",
      "ufo",
      "black_hole",
      "space_whale",
    ];

    final collectedCount =
        allObjects.where((type) => discovered.contains(type)).length;

    final percent =
    ((collectedCount / allObjects.length) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("宇宙図鑑"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Text(
            "達成率 $percent%",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "$collectedCount / ${allObjects.length}",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: collectedCount / allObjects.length,
              minHeight: 10,
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: allObjects.length,
              itemBuilder: (context, index) {
                final type = allObjects[index];
                final found = discovered.contains(type);

                return Card(
                  child: Opacity(
                    opacity: found ? 1.0 : 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildCatalogImage(type),
                        const SizedBox(height: 8),
                        Text(
                          displayName(type),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          found ? "発見済み" : "未発見",
                          style: TextStyle(
                            fontSize: 12,
                            color: found ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildCatalogImage(String type) {
  if (type.startsWith("small_star_")) {
    final number = type.split("_").last;

    return Image.asset(
      "assets/stars/star$number.png",
      width: 36,
      height: 36,
      filterQuality: FilterQuality.none,
    );
  }

  switch (type) {
    case "blue_star":
      return Image.asset(
        "assets/objects/blue_star.png",
        width: 40,
        height: 40,
        filterQuality: FilterQuality.none,
      );

    case "shooting_star":
      return Image.asset(
        "assets/objects/shooting_star.png",
        width: 45,
        height: 45,
        filterQuality: FilterQuality.none,
      );

    case "mars":
      return Image.asset(
        "assets/objects/mars.png",
        width: 50,
        height: 50,
        filterQuality: FilterQuality.none,
      );

    case "jupiter":
      return Image.asset(
        "assets/objects/jupiter.png",
        width: 60,
        height: 60,
        filterQuality: FilterQuality.none,
      );

    case "galaxy":
      return Image.asset(
        "assets/objects/galaxy.png",
        width: 70,
        height: 70,
        filterQuality: FilterQuality.none,
      );

    case "satellite":
      return Image.asset(
        "assets/objects/satellite.png",
        width: 45,
        height: 45,
        filterQuality: FilterQuality.none,
      );

    case "rocket":
      return Image.asset(
        "assets/objects/rocket.png",
        width: 50,
        height: 50,
        filterQuality: FilterQuality.none,
      );

    case "space_station":
      return Image.asset(
        "assets/objects/space_station.png",
        width: 60,
        height: 60,
        filterQuality: FilterQuality.none,
      );

    case "probe":
      return Image.asset(
        "assets/objects/probe.png",
        width: 45,
        height: 45,
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
        width: 70,
        height: 70,
        filterQuality: FilterQuality.none,
      );

    case "space_whale":
      return Image.asset(
        "assets/objects/space_whale.png",
        width: 80,
        height: 80,
        filterQuality: FilterQuality.none,
      );

    default:
      return const Icon(
        Icons.help_outline,
        size: 40,
      );
  }
}

String displayName(String type) {
  switch (type) {
    case "small_star_0":
      return "小さな星1";
    case "small_star_1":
      return "小さな星2";
    case "small_star_2":
      return "小さな星3";
    case "small_star_3":
      return "小さな星4";
    case "small_star_4":
      return "小さな星5";
    case "small_star_5":
      return "小さな星6";
    case "small_star_6":
      return "小さな星7";
    case "small_star_7":
      return "小さな星8";
    case "small_star_8":
      return "小さな星9";
    case "small_star_9":
      return "小さな星10";
    case "blue_star":
      return "青い星";
    case "shooting_star":
      return "流れ星";
    case "mars":
      return "火星";
    case "jupiter":
      return "木星";
    case "galaxy":
      return "銀河";
    case "satellite":
      return "人工衛星";
    case "rocket":
      return "ロケット";
    case "space_station":
      return "宇宙ステーション";
    case "probe":
      return "探査機";
    case "ufo":
      return "UFO";

    case "black_hole":
      return "ブラックホール";

    case "space_whale":
      return "宇宙クジラ";
    default:
      return type;
  }
}