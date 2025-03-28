import 'package:flutter/material.dart';
import 'explore_by_interest_screen.dart';

class InterestListScreen extends StatelessWidget {
  final Map<String, List<String>> interestChallenges = {
    'Fotografía': [
      'Toma una foto con un solo color dominante.',
      'Captura una sombra interesante.',
      'Haz una foto en blanco y negro de algo cotidiano.'
    ],
    'Escritura': [
      'Escribe una historia que comience con “Nunca pensé que volvería ahí…”',
      'Describe tu día como si fuera una escena de una novela de misterio.',
      'Escribe un poema sobre una taza de café.'
    ],
    'Dibujo': [
      'Dibuja tu comida usando solo formas geométricas.',
      'Haz un retrato sin levantar el lápiz del papel.',
      'Dibuja un animal que no existe.'
    ],
    // Añade más si quieres...
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Explora por intereses')),
      body: ListView(
        children: interestChallenges.keys.map((interest) {
          return ListTile(
            title: Text(interest),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExploreByInterestScreen(
                    interest: interest,
                    challenges: interestChallenges[interest]!,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}