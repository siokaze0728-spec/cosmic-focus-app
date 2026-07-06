import 'dart:math';

import 'focus_select_screen.dart';
import 'universe_screen.dart';
import 'package:flutter/material.dart';
import '../data/game_storage.dart';
import 'shop_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';
import 'catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _tutorialChecked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  Future<void> _showTutorialIfNeeded() async {
    if (!mounted || _tutorialChecked || GameStorage.getTutorialSeen()) {
      return;
    }

    _tutorialChecked = true;

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const TutorialScreen(),
      ),
    );
  }

  static const _menuItems = [
    _HomeMenuItem(
      label: 'Focus',
      subtitle: '集中する',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFFFFC857),
    ),
    _HomeMenuItem(
      label: 'My Universe',
      subtitle: '自分の宇宙',
      icon: Icons.public_rounded,
      color: Color(0xFF80DEEA),
    ),
    _HomeMenuItem(
      label: 'History',
      subtitle: '集中履歴',
      icon: Icons.timeline_rounded,
      color: Color(0xFFA5D6A7),
    ),
    _HomeMenuItem(
      label: 'Shop',
      subtitle: 'ショップ',
      icon: Icons.storefront_rounded,
      color: Color(0xFFFFAB91),
    ),
    _HomeMenuItem(
      label: 'Catalog',
      subtitle: '宇宙図鑑',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFFB39DDB),
    ),
    _HomeMenuItem(
      label: 'Settings',
      subtitle: '設定',
      icon: Icons.settings_rounded,
      color: Color(0xFFCFD8DC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final coins = GameStorage.getCoins();
    final rank = GameStorage.getRank();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cosmic Focus'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF070B2D),
              Color(0xFF151047),
              Color(0xFF301452),
              Color(0xFF05050F),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: _StarryHomeBackground(),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 46,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StatusCard(coins: coins, rank: rank),
                          const SizedBox(height: 24),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _menuItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.28,
                            ),
                            itemBuilder: (context, index) {
                              return _CosmicMenuButton(
                                item: _menuItems[index],
                                onTap: () => _openMenu(index),
                              );
                            },
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
      ),
    );
  }

  Future<void> _openMenu(int index) async {
    switch (index) {
      case 0:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FocusSelectScreen(),
          ),
        );

        setState(() {});
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UniverseScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryScreen(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ShopScreen(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CatalogScreen(),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SettingsScreen(),
          ),
        );
        break;
    }
  }
}

class _HomeMenuItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _HomeMenuItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _StatusCard extends StatelessWidget {
  final int coins;
  final String rank;

  const _StatusCard({
    required this.coins,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withOpacity(0.26),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Journey through your focus galaxy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '🪙 $coins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rank,
            style: const TextStyle(
              color: Color(0xFFFFF2A8),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmicMenuButton extends StatelessWidget {
  final _HomeMenuItem item;
  final VoidCallback onTap;

  const _CosmicMenuButton({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.07),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withOpacity(0.18),
                  border: Border.all(color: item.color.withOpacity(0.55)),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 27,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarryHomeBackground extends StatelessWidget {
  const _StarryHomeBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarryHomeBackgroundPainter(),
    );
  }
}

class _StarryHomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final starPaint = Paint();

    for (var i = 0; i < 95; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.7 + random.nextDouble() * 1.7;
      final opacity = 0.32 + random.nextDouble() * 0.58;

      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C4DFF).withOpacity(0.24),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.22, size.height * 0.2),
          radius: size.width * 0.58,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.2),
      size.width * 0.58,
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StarryHomeBackgroundPainter oldDelegate) {
    return false;
  }
}
