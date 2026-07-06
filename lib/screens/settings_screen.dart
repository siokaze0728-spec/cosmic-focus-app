import 'package:flutter/material.dart';
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