import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/challenge_helper.dart';
import '../utils/personal_challenge_helper.dart';

class DailyChallengeScreen extends StatefulWidget {
  final String challenge;
  final bool isPersonal;

  const DailyChallengeScreen({
    super.key,
    required this.challenge,
    this.isPersonal = false,
  });

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _checkCompleted();
  }

  Future<void> _checkCompleted() async {
    if (widget.isPersonal) {
      final completedList = await getCompletedChallengesForInterest(_extractInterest());
      setState(() {
        _completed = completedList.contains(widget.challenge);
      });
    } else {
      final done = await isChallengeCompleted();
      setState(() {
        _completed = done;
      });
    }
  }

  Future<void> _markAsCompleted() async {
    if (widget.isPersonal) {
      await markPersonalChallengeAsCompleted(_extractInterest(), widget.challenge);
    } else {
      await markChallengeAsCompleted();
    }

    setState(() {
      _completed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Reto completado! Bien hecho.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _extractInterest() {
    final match = RegExp(r'^\[(.*?)\]').firstMatch(widget.challenge);
    return match != null ? match.group(1)! : 'General';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isPersonal ? 'Reto Personalizado' : 'Reto del Día')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu reto:', style: TextStyle(fontSize: 22)),
            SizedBox(height: 16),
            Text(
              widget.challenge,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            _completed
                ? Column(
                    children: [
                      Icon(Icons.celebration, color: Colors.green, size: 48),
                      SizedBox(height: 8),
                      Text('¡Ya completaste este reto!', style: TextStyle(color: Colors.green, fontSize: 18)),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _markAsCompleted,
                    child: Text('¡Hecho!'),
                  ),
          ],
        ),
      ),
    );
  }
}