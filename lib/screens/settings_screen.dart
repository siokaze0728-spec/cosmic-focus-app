import 'package:flutter/material.dart';
import '../data/bgm_track.dart';
import '../data/game_storage.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("設定"),
      ),
      body: ListView(
        children: [

          _BgmEnabledTile(),

          _BgmVolumeTile(),

          _BgmSelectTile(),

          _AudioCreditsTile(),

          _SeEnabledTile(),

          ListTile(
            leading: const Icon(Icons.school),
            title: const Text("チュートリアルを見る"),
            subtitle: const Text(
              "Cosmic Focusの使い方をもう一度確認します",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const TutorialScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("データ初期化"),
            subtitle: const Text(
              "全ての進行状況を削除します",
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("確認"),
                  content: const Text(
                    "本当に初期化しますか？",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("キャンセル"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        await GameStorage.resetAllData();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("データを初期化しました"),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("初期化"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BgmVolumeTile extends StatefulWidget {
  @override
  State<_BgmVolumeTile> createState() => _BgmVolumeTileState();
}

class _BgmVolumeTileState extends State<_BgmVolumeTile> {
  late double volume;

  @override
  void initState() {
    super.initState();
    volume = GameStorage.getBgmVolume();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: const Text("BGM音量"),
      subtitle: Slider(
        value: volume,
        min: 0,
        max: 1,
        divisions: 10,
        label: "${(volume * 100).round()}%",
        onChanged: (value) {
          setState(() {
            volume = value;
          });

          GameStorage.setBgmVolume(value);
        },
      ),
    );
  }
}

class _BgmEnabledTile extends StatefulWidget {
  @override
  State<_BgmEnabledTile> createState() => _BgmEnabledTileState();
}

class _BgmEnabledTileState extends State<_BgmEnabledTile> {
  late bool enabled;

  @override
  void initState() {
    super.initState();
    enabled = GameStorage.getBgmEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.music_note),
      title: const Text("BGM"),
      subtitle: const Text("BGMを再生する"),
      value: enabled,
      onChanged: (value) {
        setState(() {
          enabled = value;
        });

        GameStorage.setBgmEnabled(value);
      },
    );
  }
}


class _BgmSelectTile extends StatefulWidget {
  @override
  State<_BgmSelectTile> createState() => _BgmSelectTileState();
}

class _BgmSelectTileState extends State<_BgmSelectTile> {
  late Future<List<BgmTrack>> availableTracksFuture;
  String? selectedAsset;

  @override
  void initState() {
    super.initState();
    availableTracksFuture = loadAvailableBgmTracks();
    _loadSelectedBgm();
  }

  Future<void> _loadSelectedBgm() async {
    final asset = await GameStorage.getSelectedBgmAsset();

    if (!mounted) return;

    setState(() {
      selectedAsset = asset;
    });
  }

  Future<void> _selectBgm(List<BgmTrack> tracks) async {
    final selectedTrack = await showDialog<BgmTrack>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("BGMを選択"),
        children: tracks
            .map(
              (track) => RadioListTile<String>(
                title: Text(track.title),
                subtitle: Text(track.asset.split('/').last),
                value: track.asset,
                groupValue: selectedAsset,
                onChanged: (_) {
                  Navigator.pop(context, track);
                },
              ),
            )
            .toList(),
      ),
    );

    if (selectedTrack == null) {
      return;
    }

    await GameStorage.setSelectedBgmAsset(selectedTrack.asset);

    if (!mounted) return;

    setState(() {
      selectedAsset = selectedTrack.asset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BgmTrack>>(
      future: availableTracksFuture,
      builder: (context, snapshot) {
        final tracks = snapshot.data ?? const <BgmTrack>[];
        final selectedTrack = tracks.cast<BgmTrack?>().firstWhere(
              (track) => track?.asset == selectedAsset,
              orElse: () => null,
            );

        return ListTile(
          leading: const Icon(Icons.library_music),
          title: const Text("BGMを選択"),
          subtitle: Text(selectedTrack?.title ?? "読み込み中"),
          enabled: tracks.isNotEmpty,
          onTap: tracks.isEmpty ? null : () => _selectBgm(tracks),
        );
      },
    );
  }
}

class _AudioCreditsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text("使用音源"),
      subtitle: const Text("BGMのクレジットを表示します"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("使用音源"),
            content: SizedBox(
              width: double.maxFinite,
              child: FutureBuilder<List<BgmTrack>>(
                future: loadAvailableBgmTracks(),
                builder: (context, snapshot) {
                  final tracks = snapshot.data ?? const <BgmTrack>[];

                  if (tracks.isEmpty) {
                    return const Text("表示できる音源情報がありません");
                  }

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tracks
                          .map(
                            (track) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("曲名：${track.title}"),
                                  Text("作者：${track.author}"),
                                  Text("ライセンス：${track.license}"),
                                  Text("入手元：${track.source}"),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("閉じる"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeEnabledTile extends StatefulWidget {
  @override
  State<_SeEnabledTile> createState() => _SeEnabledTileState();
}

class _SeEnabledTileState extends State<_SeEnabledTile> {
  late bool enabled;

  @override
  void initState() {
    super.initState();
    enabled = GameStorage.getSeEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.volume_up),
      title: const Text("効果音"),
      subtitle: const Text("効果音を再生する"),
      value: enabled,
      onChanged: (value) {
        setState(() {
          enabled = value;
        });

        GameStorage.setSeEnabled(value);
      },
    );
  }
}