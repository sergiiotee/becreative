import 'package:flutter/material.dart';
import '../utils/progressive_challenge_helper.dart';
import 'challenge_response_screen.dart';

class ProgressiveChallengesScreen extends StatefulWidget {
  final String interest;

  const ProgressiveChallengesScreen({super.key, required this.interest});

  @override
  State<ProgressiveChallengesScreen> createState() => _ProgressiveChallengesScreenState();
}

class _ProgressiveChallengesScreenState extends State<ProgressiveChallengesScreen> {
  List<String> _allChallenges = [];
  Set<String> _completedChallenges = {};
  int _unlockedCount = 5;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final all = challengeBank[widget.interest] ?? [];
    final completed = await getCompletedChallengesForInterest(widget.interest);

    final previousUnlocked = _unlockedCount;

    int newUnlocked;
    if (completed.length < 5) {
      newUnlocked = 5;
    } else if (completed.length >= 5 && completed.length < 30) {
      newUnlocked = 30;
    } else {
      final bloquesExtra = ((completed.length - 30) / 10).floor();
      newUnlocked = (30 + bloquesExtra * 10).clamp(30, all.length);
    }

    setState(() {
      _allChallenges = all;
      _completedChallenges = completed.toSet();
      _unlockedCount = newUnlocked;
    });

    if (newUnlocked > previousUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Nuevos retos desbloqueados!'),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  Future<void> _markCompleted(String challenge) async {
    await markChallengeProgress(widget.interest, challenge);
    await _loadChallenges();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Reto completado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedChallenges = _allChallenges.take(_unlockedCount).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.interest)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Progreso: ${_completedChallenges.length}/$_unlockedCount completados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: unlockedChallenges.length,
              itemBuilder: (context, index) {
                final challenge = unlockedChallenges[index];
                final isDone = _completedChallenges.contains(challenge);

                return ListTile(
                  leading: Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? Colors.green : null,
                  ),
                  title: Text(challenge),
                  onTap: isDone
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChallengeResponseScreen(
                                interest: widget.interest,
                                challenge: challenge,
                              ),
                            ),
                          ).then((_) => _loadChallenges()); // recargar al volver
                        },
                );
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> saveChallengeResponse(String interest, String challenge, {String? text, String? imagePath}) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  if (text != null) await prefs.setString('response_text_$keyPrefix', text);
  if (imagePath != null) await prefs.setString('response_image_$keyPrefix', imagePath);
}

Future<Map<String, String?>> getChallengeResponse(String interest, String challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  final text = prefs.getString('response_text_$keyPrefix');
  final imagePath = prefs.getString('response_image_$keyPrefix');
  return {'text': text, 'imagePath': imagePath};
}

Future<bool> isChallengeCompleted(String interest, String challenge) async {
  final list = await getCompletedChallengesForInterest(interest);
  return list.contains(challenge);
}

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveChallengeResponse(String interest, String challenge,
    {String? text, String? imagePath}) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  if (text != null) await prefs.setString('response_text_$keyPrefix', text);
  if (imagePath != null) await prefs.setString('response_image_$keyPrefix', imagePath);
}

Future<Map<String, String?>> getChallengeResponse(String interest, String challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final keyPrefix = '${interest}_${challenge.hashCode}';
  final text = prefs.getString('response_text_$keyPrefix');
  final imagePath = prefs.getString('response_image_$keyPrefix');
  return {'text': text, 'imagePath': imagePath};
}

Future<bool> isChallengeCompleted(String interest, String challenge) async {
  final completedList = await getCompletedChallengesForInterest(interest);
  return completedList.contains(challenge);
}