import 'package:hive/hive.dart';

import '../models/celestial_object.dart';
import 'bgm_track.dart';


class GameStorage {
  static const String tutorialSeenKey = "tutorialSeen";
  static const String selectedBgmAssetKey = "selectedBgmAsset";

  static bool getBgmEnabled() {
    return box.get(
      "bgmEnabled",
      defaultValue: true,
    );
  }

  static void setBgmEnabled(bool enabled) {
    box.put(
      "bgmEnabled",
      enabled,
    );
  }

  static bool getSeEnabled() {
    return box.get(
      "seEnabled",
      defaultValue: true,
    );
  }

  static void setSeEnabled(bool enabled) {
    box.put(
      "seEnabled",
      enabled,
    );
  }

  static Future<String> getSelectedBgmAsset() async {
    final selectedAsset = box.get(
      selectedBgmAssetKey,
      defaultValue: defaultBgmTrack.asset,
    ) as String;

    final track = await resolveBgmTrack(selectedAsset);
    return track.asset;
  }

  static Future<void> setSelectedBgmAsset(String asset) async {
    final track = await resolveBgmTrack(asset);
    await box.put(
      selectedBgmAssetKey,
      track.asset,
    );
  }

  static double getBgmVolume() {
    return box.get(
      "bgmVolume",
      defaultValue: 0.5,
    );
  }

  static void setBgmVolume(double volume) {
    box.put(
      "bgmVolume",
      volume,
    );
  }

  static bool getTutorialSeen() {
    return box.get(
      tutorialSeenKey,
      defaultValue: false,
    );
  }

  static Future<void> setTutorialSeen(bool seen) async {
    await box.put(
      tutorialSeenKey,
      seen,
    );
  }

  static Future<void> resetAllData() async {
    await box.clear();
  }

  static int getTodayFocusMinutes() {
    final now = DateTime.now();
    final records = getFocusRecords();

    int total = 0;

    for (final record in records) {
      final date = DateTime.parse(record["date"] as String);

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        total += record["minutes"] as int;
      }
    }

    return total;
  }

  static int getThisMonthFocusMinutes() {
    final now = DateTime.now();
    final records = getFocusRecords();

    int total = 0;

    for (final record in records) {
      final date = DateTime.parse(record["date"] as String);

      if (date.year == now.year &&
          date.month == now.month) {
        total += record["minutes"] as int;
      }
    }

    return total;
  }

  static int getThisWeekFocusMinutes() {
    final now = DateTime.now();

    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    );

    final records = getFocusRecords();

    int total = 0;

    for (final record in records) {
      final date = DateTime.parse(record["date"] as String);

      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(now.add(const Duration(days: 1)))) {
        total += record["minutes"] as int;
      }
    }

    return total;
  }


  static List<Map> getFocusRecords() {
    final rawList = box.get(
      "focusRecords",
      defaultValue: [],
    );

    return List<Map>.from(rawList);
  }

  static int addFocusRecord({
    required int minutes,
    required int coins,
    required String objectType,
    required DateTime startedAt,
    required DateTime endedAt,
    bool rewardDoubled = false,
  }) {
    final records = getFocusRecords();

    records.add({
      "date": endedAt.toIso8601String(),
      "startDate": startedAt.toIso8601String(),
      "endDate": endedAt.toIso8601String(),
      "minutes": minutes,
      "coins": coins,
      "baseCoins": rewardDoubled ? coins ~/ 2 : coins,
      "objectType": objectType,
      "rewardMultiplier": rewardDoubled ? 2 : 1,
      "rewardDoubled": rewardDoubled,
    });

    box.put("focusRecords", records);

    return records.length - 1;
  }

  static void updateFocusRecordReward({
    required int index,
    required int coins,
    required bool rewardDoubled,
  }) {
    final records = getFocusRecords();

    if (index < 0 || index >= records.length) {
      return;
    }

    final record = Map<String, dynamic>.from(records[index]);

    record["coins"] = coins;
    record["baseCoins"] = rewardDoubled ? coins ~/ 2 : coins;
    record["rewardMultiplier"] = rewardDoubled ? 2 : 1;
    record["rewardDoubled"] = rewardDoubled;

    records[index] = record;

    box.put("focusRecords", records);
  }

  static int getTotalFocusMinutes() {


    final records = getFocusRecords();

    int total = 0;

    for (final record in records) {
      total += record["minutes"] as int;
    }

    return total;
  }


  static bool spendCoins(int amount) {
    final current = getCoins();

    if (current < amount) {
      return false;
    }

    box.put(
      "coins",
      current - amount,
    );

    return true;
  }

  static Box get box => Hive.box('gameData');

  static List<CelestialObject> getObjects() {
    final rawList = box.get(
      "objects",
      defaultValue: [],
    );

    return List<Map>.from(rawList)
        .map((map) => CelestialObject.fromMap(map))
        .toList();
  }

  static void saveObjects(
      List<CelestialObject> objects,
      ) {
    final rawList = objects
        .map((object) => object.toMap())
        .toList();

    box.put("objects", rawList);
  }

  static void addObject(String type) {
    final objects = getObjects();

    objects.add(
      CelestialObject(
        type: type,
        x: 100 + objects.length * 40,
        y: 200,
        size: 1.0,
        rotation: 0.0,
      ),
    );

    saveObjects(objects);
  }

  static int getCoins() {
    return box.get(
      "coins",
      defaultValue: 0,
    );
  }

  static void addCoins(int amount) {
    final current = getCoins();

    box.put(
      "coins",
      current + amount,
    );
  }
  static String getRank() {
    final total = getTotalFocusMinutes();

    if (total >= 15000) {
      return "宇宙創造主";
    }

    if (total >= 5000) {
      return "銀河管理者";
    }

    if (total >= 1800) {
      return "恒星管理者";
    }

    if (total >= 600) {
      return "惑星開拓者";
    }

    if (total >= 120) {
      return "宇宙飛行士";
    }

    return "新人観測者";
  }

  static String getRankByMinutes(int total) {
    if (total >= 15000) {
      return "宇宙創造主";
    }

    if (total >= 5000) {
      return "銀河管理者";
    }

    if (total >= 1800) {
      return "恒星管理者";
    }

    if (total >= 600) {
      return "惑星開拓者";
    }

    if (total >= 120) {
      return "宇宙飛行士";
    }

    return "新人観測者";
  }

}
