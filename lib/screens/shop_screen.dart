import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/game_storage.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {

  final AudioPlayer sePlayer = AudioPlayer();

  final items = [
    {
      "name": "人工衛星",
      "type": "satellite",
      "price": 100,
      "icon": Icons.satellite_alt,
    },
    {
      "name": "ロケット",
      "type": "rocket",
      "price": 200,
      "icon": Icons.rocket_launch,
    },
    {
      "name": "宇宙ステーション",
      "type": "space_station",
      "price": 500,
      "icon": Icons.public,
    },
    {
      "name": "探査機",
      "type": "probe",
      "price": 800,
      "icon": Icons.settings_input_antenna,
    },
  ];

  void buyItem(Map<String, dynamic> item) {
    final price = item["price"] as int;
    final type = item["type"] as String;

    final success = GameStorage.spendCoins(price);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("コインが足りません"),
        ),
      );
      return;
    }

    GameStorage.addObject(type);

    if (GameStorage.getSeEnabled()) {
      sePlayer.play(
        AssetSource('sounds/buy.mp3'),
      );
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item["name"]}を購入しました"),
      ),
    );
  }

  @override
  void dispose() {
    sePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coins = GameStorage.getCoins();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ショップ"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Text(
            "🪙 $coins",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      item["icon"] as IconData,
                      size: 36,
                    ),
                    title: Text(item["name"] as String),
                    subtitle: Text("${item["price"]} コイン"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        buyItem(item);
                      },
                      child: const Text("購入"),
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