import 'dart:convert';

import 'package:flutter/services.dart';

class BgmTrack {
  const BgmTrack({
    required this.asset,
    required this.title,
    required this.author,
    required this.license,
    required this.source,
  });

  final String asset;
  final String title;
  final String author;
  final String license;
  final String source;

  String get assetSourcePath => asset.replaceFirst('assets/', '');
}

const List<BgmTrack> bgmTracks = [
  BgmTrack(
    asset: 'assets/music/space_bgm.mp3',
    title: '宇宙旅行',
    author: '未設定',
    license: '未設定',
    source: '未設定',
  ),
  BgmTrack(
    asset: 'assets/music/space_bgm_2.mp3',
    title: '静かな星空',
    author: '未設定',
    license: '未設定',
    source: '未設定',
  ),
  BgmTrack(
    asset: 'assets/music/space_bgm_3.mp3',
    title: '銀河の集中',
    author: '未設定',
    license: '未設定',
    source: '未設定',
  ),
];

const BgmTrack defaultBgmTrack = bgmTracks.first;

Future<Set<String>> loadBundledAssetKeys() async {
  try {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    return manifest.keys.toSet();
  } catch (_) {
    return {defaultBgmTrack.asset};
  }
}

Future<List<BgmTrack>> loadAvailableBgmTracks() async {
  final assetKeys = await loadBundledAssetKeys();
  final availableTracks = bgmTracks
      .where((track) => assetKeys.contains(track.asset))
      .toList(growable: false);

  if (availableTracks.isEmpty) {
    return [defaultBgmTrack];
  }

  return availableTracks;
}

Future<BgmTrack> resolveBgmTrack(String? asset) async {
  final availableTracks = await loadAvailableBgmTracks();

  for (final track in availableTracks) {
    if (track.asset == asset) {
      return track;
    }
  }

  return availableTracks.first;
}
