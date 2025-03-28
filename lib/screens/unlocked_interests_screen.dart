import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'progressive_challenges_screen.dart'; // que haremos en el paso 2

class UnlockedInterestsScreen extends StatefulWidget {
  const UnlockedInterestsScreen({super.key});

  @override
  State<UnlockedInterestsScreen> createState() => _UnlockedInterestsScreenState();
}

class _UnlockedInterestsScreenState extends State<UnlockedInterestsScreen> {
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('user_interests') ?? [];
    setState(() {
      _interests = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tus intereses')),
      body: _interests.isEmpty
          ? Center(child: Text('Aún no has seleccionado intereses.'))
          : ListView.builder(
              itemCount: _interests.length,
              itemBuilder: (context, index) {
                final interest = _interests[index];
                return ListTile(
                  title: Text(interest),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressiveChallengesScreen(interest: interest),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}