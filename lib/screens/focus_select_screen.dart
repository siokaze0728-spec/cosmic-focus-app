import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'focus_screen.dart';

class FocusSelectScreen extends StatefulWidget {
  const FocusSelectScreen({super.key});

  @override
  State<FocusSelectScreen> createState() => _FocusSelectScreenState();
}

class _FocusSelectScreenState extends State<FocusSelectScreen> {
  static const int minMinutes = 15;
  static const int maxMinutes = 240;

  Duration selectedDuration = const Duration(minutes: minMinutes);

  int get selectedMinutes {
    final minutes = selectedDuration.inMinutes;

    if (minutes < minMinutes) {
      return minMinutes;
    }

    if (minutes > maxMinutes) {
      return maxMinutes;
    }

    return minutes;
  }

  void startFocus() {
    final minutes = selectedDuration.inMinutes;

    if (minutes < minMinutes || minutes > maxMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("15分〜4時間の範囲で選択してください"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusScreen(
          minute: minutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("集中時間選択"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "時計を回して集中時間を選択",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "$selectedMinutes 分",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                minuteInterval: 15,
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (duration) {
                  setState(() {
                    selectedDuration = duration;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startFocus,
                child: const Text("星間飛行を開始"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
