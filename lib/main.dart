import 'package:flutter/material.dart';

void main() {
  runApp(const PoupaiApp());
}

class PoupaiApp extends StatelessWidget {
  const PoupaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poupaí',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bem-vindo ao Poupaí'),
        ),
        body: const Center(
          child: Text('Nosso app começa aqui!'),
        ),
      ),
    );
  }
}