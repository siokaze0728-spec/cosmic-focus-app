import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/game_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List<Map> getRecordsForDay(DateTime day) {
    final records = GameStorage.getFocusRecords();

    return records.where((record) {
      final date = DateTime.parse(record["date"] as String);

      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  int getMinutesForDay(DateTime day) {
    final records = getRecordsForDay(day);

    int total = 0;

    for (final record in records) {
      total += record["minutes"] as int;
    }

    return total;
  }

  String formatClock(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  DateTime recordStartTime(Map record, DateTime endTime) {
    final startDate = record["startDate"];

    if (startDate is String) {
      return DateTime.parse(startDate);
    }

    return endTime.subtract(
      Duration(minutes: record["minutes"] as int),
    );
  }

  DateTime recordEndTime(Map record) {
    final endDate = record["endDate"];

    if (endDate is String) {
      return DateTime.parse(endDate);
    }

    return DateTime.parse(record["date"] as String);
  }

  String rewardText(Map record) {
    final coins = record["coins"] as int;
    final multiplier = record["rewardMultiplier"] as int? ?? 1;

    if (multiplier > 1) {
      return "+$coins 🪙（広告${multiplier}倍）";
    }

    return "+$coins 🪙";
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecords =
    getRecordsForDay(selectedDay).reversed.toList();

    final todayMinutes = GameStorage.getTodayFocusMinutes();
    final weekMinutes = GameStorage.getThisWeekFocusMinutes();
    final monthMinutes = GameStorage.getThisMonthFocusMinutes();
    final totalMinutes = GameStorage.getTotalFocusMinutes();

    return Scaffold(
      appBar: AppBar(
        title: const Text("集中履歴"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2035, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: "月",
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final minutes = getMinutesForDay(day);

                if (minutes == 0) {
                  return null;
                }

                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("今日：$todayMinutes 分"),
                Text("今週：$weekMinutes 分"),
                Text("今月：$monthMinutes 分"),
                Text("総計：$totalMinutes 分"),
              ],
            ),
          ),

          const Divider(),

          Text(
            "${selectedDay.year}/${selectedDay.month}/${selectedDay.day} の履歴",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: selectedRecords.length,
              itemBuilder: (context, index) {
                final record = selectedRecords[index];

                final endTime = recordEndTime(record);
                final startTime = recordStartTime(record, endTime);

                return ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text("${record["minutes"]} 分 集中"),
                  subtitle: Text(
                    "${formatClock(startTime)}〜${formatClock(endTime)}",
                  ),
                  trailing: Text(rewardText(record)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}