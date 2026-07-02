import 'focus_select_screen.dart';
import 'universe_screen.dart';
import 'package:flutter/material.dart';
import '../data/game_storage.dart';
import 'shop_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    final coins =
    GameStorage.getCoins();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmic Focus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "🪙 $coins",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              GameStorage.getRank(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FocusSelectScreen(),
                  ),
                );

                setState(() {});
              },
              child: const Text("集中する"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UniverseScreen(),
                  ),
                );
              },
              child: const Text('自分の宇宙を見る'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              child: const Text('集中履歴'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShopScreen(),
                  ),
                );
              },
              child: const Text('ショップ'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CatalogScreen(),
                  ),
                );
              },
              child: const Text('宇宙図鑑'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const SettingsScreen(),
                  ),
                );
              },
              child: const Text('設定'),
            ),



          ],
        ),
      ),
    );
  }
}