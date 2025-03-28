import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/progressive_challenge_helper.dart';

class ProgressSummaryScreen extends StatefulWidget {
  const ProgressSummaryScreen({super.key});

  @override
  State<ProgressSummaryScreen> createState() => _ProgressSummaryScreenState();
}

class _ProgressSummaryScreenState extends State<ProgressSummaryScreen> {
  List<String> _userInterests = [];
  Map<String, int> _completedCount = {};
  Map<String, int> _unlockedCount = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final interests = prefs.getStringList('user_interests') ?? [];

    final Map<String, int> completed = {};
    final Map<String, int> unlocked = {};

    for (final interest in interests) {
      final all = challengeBank[interest] ?? [];
      final done = await getCompletedChallengesForInterest(interest);

      int unlockedCount;
      if (done.length < 5) {
        unlockedCount = 5;
      } else if (done.length >= 5 && done.length < 30) {
        unlockedCount = 30;
      } else {
        final extra = ((done.length - 30) / 10).floor();
        unlockedCount = (30 + extra * 10).clamp(30, all.length);
      }

      completed[interest] = done.length;
      unlocked[interest] = unlockedCount;
    }

    setState(() {
      _userInterests = interests;
      _completedCount = completed;
      _unlockedCount = unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progreso por interés')),
      body: _userInterests.isEmpty
          ? Center(child: Text('Aún no has seleccionado intereses.'))
          : ListView.builder(
              itemCount: _userInterests.length,
              itemBuilder: (context, index) {
                final interest = _userInterests[index];
                final completed = _completedCount[interest] ?? 0;
                final total = _unlockedCount[interest] ?? 0;
                final progress = total > 0 ? completed / total : 0.0;

                return ListTile(
                    leading: completed == total && total > 0
                        ? Icon(Icons.emoji_events, color: Colors.amber)
                        : null,
                    title: Text(interest),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: Colors.indigo,
                            minHeight: 6,
                        ),
                        SizedBox(height: 4),
                        Text('$completed de $total completados'),
                        ],
                    ),
                );
              },
            ),
    );
  }
}