import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../data/game_storage.dart';

class FocusScreen extends StatefulWidget {
  final int minute;

  const FocusScreen({
    super.key,
    required this.minute,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with WidgetsBindingObserver,
        SingleTickerProviderStateMixin {
  late int remainingSeconds;
  late DateTime focusStartedAt;
  late DateTime focusEndsAt;

  Timer? timer;

  bool isBgmPlaying = false;
  bool hasCompleted = false;
  bool isShowingRewardedAd = false;
  StreamSubscription<void>? bgmCompleteSubscription;

  Future<void> startBgm() async {
    await bgmCompleteSubscription?.cancel();
    bgmCompleteSubscription = null;

    if (!GameStorage.getBgmEnabled()) {
      isBgmPlaying = false;
      await player.stop();
      return;
    }

    isBgmPlaying = true;

    bgmCompleteSubscription = player.onPlayerComplete.listen((_) async {
      if (!mounted || !isBgmPlaying || !GameStorage.getBgmEnabled()) {
        return;
      }

      await player.stop();
      await player.play(
        AssetSource('music/space_bgm.mp3'),
      );
    });

    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(GameStorage.getBgmVolume());

    await player.stop();
    await player.play(
      AssetSource('music/space_bgm.mp3'),
    );
  }

  Future<void> pauseBgmForAd() async {
    if (!isBgmPlaying) {
      return;
    }

    await player.pause();
  }

  Future<void> resumeBgmIfNeeded() async {
    if (!mounted || !isBgmPlaying || !GameStorage.getBgmEnabled()) {
      return;
    }

    await startBgm();
  }

  void restoreBgmAfterRewardedAd() {
    isShowingRewardedAd = false;

    if (mounted) {
      unawaited(startBgm());
    }
  }

  bool hasUsedContinueAd = false;

  final AudioPlayer sePlayer = AudioPlayer();

  final AudioPlayer player = AudioPlayer();

  late AnimationController astronautController;
  late Animation<double> astronautAnimation;

  RewardedAd? rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          rewardedAd = null;
        },
      ),
    );
  }

  String rewardType() {


    switch (widget.minute) {
      case 1:
        return "small_star_${Random().nextInt(10)}";

      case 15:
        return "small_star_${Random().nextInt(10)}";

      case 30:
        return "blue_star";

      case 45:
        return "shooting_star";

      case 60:
        return "mars";

      case 120:
        return "jupiter";

      case 240:
        return "galaxy";

      default:
        return "small_star";
    }
  }

  int rewardCoins() {
    switch (widget.minute) {
      case 15:
        return 10;

      case 30:
        return 20;

      case 45:
        return 35;

      case 60:
        return 50;

      case 120:
        return 120;

      case 240:
        return 300;

      default:
        return 10;
    }
  }

  String rewardName() {
    switch (widget.minute) {
      case 15:
        return "小さな星";

      case 30:
        return "青い星";

      case 45:
        return "流れ星";

      case 60:
        return "火星";

      case 120:
        return "木星";

      case 240:
        return "銀河";

      default:
        return "小さな星";
    }
  }



  @override
  void initState() {

    loadRewardedAd();

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    remainingSeconds = widget.minute * 60;
    focusStartedAt = DateTime.now();
    focusEndsAt = focusStartedAt.add(Duration(minutes: widget.minute));

    startTimer();

    astronautController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 4,
      ),
    );

    astronautAnimation = Tween<double>(
      begin: -40,
      end: 40,
    ).animate(
      CurvedAnimation(
        parent: astronautController,
        curve: Curves.easeInOut,
      ),
    );

    astronautController.repeat(
      reverse: true,
    );

    startBgm();

  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        updateRemainingTime();
      },
    );

    updateRemainingTime();
  }

  void updateRemainingTime() {
    if (hasCompleted) {
      return;
    }

    final secondsLeft = focusEndsAt.difference(DateTime.now()).inSeconds;

    if (secondsLeft > 0) {
      if (!mounted) {
        return;
      }

      setState(() {
        remainingSeconds = secondsLeft;
      });
      return;
    }

    completeFocus();
  }

  void completeFocus() {
    if (hasCompleted) {
      return;
    }

    hasCompleted = true;
    timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      remainingSeconds = 0;
    });

    final beforeTotal = GameStorage.getTotalFocusMinutes();
    final beforeRank = GameStorage.getRankByMinutes(beforeTotal);
    final earnedObjectType = rewardType();
    final earnedCoins = rewardCoins();
    final endedAt = DateTime.now();

    GameStorage.addObject(earnedObjectType);

    final rareRoll = Random().nextDouble();

    if (rareRoll < 0.005) {
      GameStorage.addObject("space_whale");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🐋 超激レア！宇宙クジラを発見した！"),
        ),
      );
    } else if (rareRoll < 0.015) {
      GameStorage.addObject("black_hole");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🕳 激レア！ブラックホールを発見した！"),
        ),
      );
    } else if (rareRoll < 0.045) {
      GameStorage.addObject("ufo");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🛸 レア！UFOを発見した！"),
        ),
      );
    }

    GameStorage.addCoins(earnedCoins);

    final recordIndex = GameStorage.addFocusRecord(
      minutes: widget.minute,
      coins: earnedCoins,
      objectType: earnedObjectType,
      startedAt: focusStartedAt,
      endedAt: endedAt,
    );

    final afterTotal = GameStorage.getTotalFocusMinutes();
    final afterRank = GameStorage.getRankByMinutes(afterTotal);
    final isRankUp = beforeRank != afterRank;

    if (GameStorage.getSeEnabled()) {
      sePlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("集中成功！"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "新しい天体を獲得しました！",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              rewardName(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "+$earnedCoins コイン",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.amber,
              ),
            ),
            if (isRankUp) ...[
              const SizedBox(height: 16),
              const Text(
                "ランクアップ！",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              Text(
                afterRank,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: rewardedAd == null
                ? null
                : () {
                    final ad = rewardedAd;
                    rewardedAd = null;
                    isShowingRewardedAd = true;
                    unawaited(pauseBgmForAd());

                    ad!.fullScreenContentCallback = FullScreenContentCallback(
                      onAdDismissedFullScreenContent: (ad) {
                        ad.dispose();
                        restoreBgmAfterRewardedAd();
                      },
                      onAdFailedToShowFullScreenContent: (ad, error) {
                        ad.dispose();
                        restoreBgmAfterRewardedAd();
                      },
                    );

                    ad.show(
                      onUserEarnedReward: (ad, reward) {
                        GameStorage.addObject(earnedObjectType);
                        GameStorage.addCoins(earnedCoins);
                        GameStorage.updateFocusRecordReward(
                          index: recordIndex,
                          coins: earnedCoins * 2,
                          rewardDoubled: true,
                        );
                      },
                    );

                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
            child: const Text("広告を見て報酬2倍"),
          ),
        ],
      ),
    );
  }

  String formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void focusFailed() {
    timer?.cancel();

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("集中失敗"),
        content: const Text(
          "アプリを離れたため失敗になりました",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("終了する"),
          ),

          if (!hasUsedContinueAd)
            TextButton(
              onPressed: () {
                watchAdAndContinue();
              },
              child: const Text("広告を見て続ける"),
            ),
        ],
      ),
    );
  }

  void watchAdAndContinue() {
    if (rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("広告の準備ができていません"),
        ),
      );
      return;
    }

    final ad = rewardedAd;
    rewardedAd = null;
    isShowingRewardedAd = true;
    unawaited(pauseBgmForAd());

    ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        restoreBgmAfterRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        restoreBgmAfterRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        hasUsedContinueAd = true;

        Navigator.pop(context);

        startTimer();

        loadRewardedAd();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        updateRemainingTime();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    isBgmPlaying = false;

    player.stop();
    bgmCompleteSubscription?.cancel();
    player.dispose();
    sePlayer.dispose();

    astronautController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("星間飛行中"),
      ),
      body: Stack(
        children: [

          Container(
            color: Colors.black,
          ),

          ...GameStorage.getObjects().map(
                (object) => Positioned(
              left: object.x,
              top: object.y,
              child: Opacity(
                opacity: 0.25,
                child: buildFocusBackgroundObject(
                  object.type,
                ),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  formatTime(),
                  style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: astronautAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      astronautAnimation.value,
                      0,
                    ),
                    child: Image.asset(
                      "assets/objects/astronaut.png",
                      width: 30,
                      height: 30,
                      filterQuality: FilterQuality.none,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildFocusBackgroundObject(
    String type,
    ) {
  switch (type) {

    case "blue_star":
      return Image.asset(
        "assets/objects/blue_star.png",
        width: 30,
      );

    case "shooting_star":
      return Image.asset(
        "assets/objects/shooting_star.png",
        width: 40,
      );

    case "mars":
      return Image.asset(
        "assets/objects/mars.png",
        width: 55,
      );

    case "jupiter":
      return Image.asset(
        "assets/objects/jupiter.png",
        width: 85,
      );

    case "galaxy":
      return Image.asset(
        "assets/objects/galaxy.png",
        width: 140,
      );

    default:
      return const SizedBox();
  }
}
