import 'package:flutter/material.dart';
import 'screens/daily_challenge_screen.dart';
import 'utils/challenge_helper.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(BeCreativeApp());
}

class BeCreativeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'becreative',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loading = false;

  void _handleStart() async {
    setState(() {
      _loading = true;
    });

    final challenge = await getDailyChallenge();

    setState(() {
      _loading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyChallengeScreen(challenge: challenge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✨ becreative',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Un reto creativo nuevo cada día.\nInspírate, crea, comparte.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleStart,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('Empezar', style: TextStyle(fontSize: 20)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: Text('Ver historial de retos'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}