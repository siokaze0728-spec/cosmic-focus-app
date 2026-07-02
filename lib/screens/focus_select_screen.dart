import 'package:flutter/material.dart';
import 'focus_screen.dart';

class FocusSelectScreen extends StatelessWidget {
  const FocusSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final times = [
      15,
      30,
      45,
      60,
      120,
      240,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("集中時間選択"),
      ),
      body: ListView.builder(
        itemCount: times.length,
        itemBuilder: (context, index) {
          final minute = times[index];

          return ListTile(
            title: Text("$minute 分"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FocusScreen(
                    minute: minute,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}