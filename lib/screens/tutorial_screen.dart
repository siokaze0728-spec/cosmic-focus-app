import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_storage.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_TutorialPageData> _pages = [
    _TutorialPageData(
      title: '集中時間を選ぼう',
      description: '時計UIで集中したい時間を選び、ロケットのように集中をスタートできます。',
      icon: Icons.timer_rounded,
      accentColor: Color(0xFFFFD166),
    ),
    _TutorialPageData(
      title: '集中すると天体を獲得',
      description: '最後まで集中できると、星や惑星などの天体とコインが手に入ります。',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF80DEEA),
    ),
    _TutorialPageData(
      title: '自分だけの宇宙を作ろう',
      description: '獲得した天体は宇宙画面に増えていき、あなた専用の銀河が広がります。',
      icon: Icons.public_rounded,
      accentColor: Color(0xFFB39DDB),
    ),
    _TutorialPageData(
      title: 'ショップと図鑑',
      description: 'コインで宇宙アイテムを購入できます。図鑑では発見済みの天体を確認できます。',
      icon: Icons.storefront_rounded,
      accentColor: Color(0xFFFFAB91),
    ),
    _TutorialPageData(
      title: '広告で報酬アップ',
      description: '広告を見ると報酬2倍や集中継続ができます。必要なときに活用しましょう。',
      icon: Icons.rocket_launch_rounded,
      accentColor: Color(0xFFA5D6A7),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishTutorial() async {
    await GameStorage.setTutorialSeen(true);

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _goNext() async {
    if (_currentPage == _pages.length - 1) {
      await _finishTutorial();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF020414),
                Color(0xFF111344),
                Color(0xFF26104A),
                Color(0xFF04040C),
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _TutorialStarField()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _finishTutorial,
                          child: const Text(
                            'スキップ',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _TutorialPage(data: _pages[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PageIndicators(
                        currentPage: _currentPage,
                        pageCount: _pages.length,
                        activeColor: page.accentColor,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: page.accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _goNext,
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'はじめる' : '次へ',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _TutorialPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class _TutorialPage extends StatelessWidget {
  final _TutorialPageData data;

  const _TutorialPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 154,
              height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accentColor.withOpacity(0.16),
                border: Border.all(
                  color: data.accentColor.withOpacity(0.72),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.accentColor.withOpacity(0.35),
                    blurRadius: 42,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                color: data.accentColor,
                size: 78,
              ),
            ),
            const SizedBox(height: 38),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.34),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.65,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;

  const _PageIndicators({
    required this.currentPage,
    required this.pageCount,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 26 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white30,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _TutorialStarField extends StatelessWidget {
  const _TutorialStarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TutorialStarFieldPainter());
  }
}

class _TutorialStarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final paint = Paint();

    for (var i = 0; i < 130; i++) {
      paint.color = Colors.white.withOpacity(
        0.28 + random.nextDouble() * 0.64,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.7 + random.nextDouble() * 1.9,
        paint,
      );
    }

    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF7C4DFF).withOpacity(0.28),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.78, size.height * 0.22),
        radius: size.width * 0.52,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.22),
      size.width * 0.52,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialStarFieldPainter oldDelegate) {
    return false;
  }
}
