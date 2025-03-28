import 'package:shared_preferences/shared_preferences.dart';

Future<void> markPersonalChallengeAsCompleted(String interest, String challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'completed_personal_$interest';
  final existing = prefs.getStringList(key) ?? [];

  if (!existing.contains(challenge)) {
    existing.add(challenge);
    await prefs.setStringList(key, existing);
  }
}

Future<List<String>> getCompletedChallengesForInterest(String interest) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'completed_personal_$interest';
  return prefs.getStringList(key) ?? [];
}