import 'package:flutter/material.dart';
import 'pages/sign_in_page.dart';
import 'pages/games_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(BattleshipApp());
}

class BattleshipApp extends StatelessWidget {
  const BattleshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battleship',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: FutureBuilder<String?>(
        future: AuthService().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data != null) {
            return const GamesPage();
          }
          return const SignInPage();
        },
      ),
      routes: {
        '/signin': (_) => const SignInPage(),
        '/games': (_) => const GamesPage(),
      },
    );
  }
}
