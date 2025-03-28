import 'package:flutter/material.dart';
import '../utils/personal_challenge_helper.dart';

class ExploreByInterestScreen extends StatefulWidget {
  final String interest;
  final List<String> challenges;

  const ExploreByInterestScreen({
    super.key,
    required this.interest,
    required this.challenges,
  });

  @override
  State<ExploreByInterestScreen> createState() => _ExploreByInterestScreenState();
}

class _ExploreByInterestScreenState extends State<ExploreByInterestScreen> {
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final list = await getCompletedChallengesForInterest(widget.interest);
    setState(() {
      _completed = list.toSet();
    });
  }

  Future<void> _markCompleted(String challenge) async {
    await markPersonalChallengeAsCompleted(widget.interest, challenge);
    setState(() {
      _completed.add(challenge);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reto marcado como completado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Retos: ${widget.interest}')),
      body: ListView.builder(
        itemCount: widget.challenges.length,
        itemBuilder: (context, index) {
          final challenge = widget.challenges[index];
          final done = _completed.contains(challenge);

          return ListTile(
            title: Text(challenge),
            trailing: Icon(
              done ? Icons.check_circle : Icons.check_circle_outline,
              color: done ? Colors.green : null,
            ),
            onTap: done
                ? null
                : () {
                    _markCompleted(challenge);
                  },
          );
        },
      ),
    );
  }
}