import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import 'play_game_page.dart';
import 'setup_game_page.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});
  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final _service = GameService();
  final _auth = AuthService();
  bool _loading = true;
  bool _showCompleted = false;
  List<dynamic> _games = [];
  String? _user;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _loading = true);
    final res = await _service.fetchGames();
    _user = await _auth.getUsername();
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _games = data['games'];
        _loading = false;
      });
    } else if (res.statusCode == 401) {
      await _auth.logout();
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load games')),
      );
    }
  }

  Future<void> _deleteGame(int id) async {
    final res = await _service.deleteGame(id);
    if (res.statusCode == 200) {
      setState(() => _games.removeWhere((g) => g['id'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game conceded')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not concede game')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battleships'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user ?? ''),
              accountEmail: const Text(''),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Game'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetupGamePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('New vs AI'),
              onTap: _showAiDialog,
            ),
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: Text(_showCompleted ? 'Show Active' : 'Show Completed'),
              onTap: () => setState(() => _showCompleted = !_showCompleted),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _auth.logout();
                Navigator.pushReplacementNamed(context, '/signin');
              },
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _games.length,
              itemBuilder: (context, i) {
                final game = _games[i];
                final status = game['status'];
                final showThis = _showCompleted
                    ? (status == 1 || status == 2)
                    : (status == 0 || status == 3);
                if (!showThis) return const SizedBox.shrink();

                final turn = game['turn'];
                final pos = game['position'];
                final title = status == 0
                    ? '#${game['id']} Waiting'
                    : '#${game['id']} ${game['player1']} vs ${game['player2']}';
                final subtitle = (turn == 0)
                    ? (status == 1
                        ? 'Player 1 Won'
                        : status == 2
                            ? 'Player 2 Won'
                            : 'Matchmaking')
                    : (turn == pos ? 'My Turn' : 'Opponent Turn');

                Widget tile = ListTile(
                  title: Text(title),
                  trailing: Text(subtitle),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayGamePage(gameId: game['id']),
                    ),
                  ),
                );

                if (_showCompleted && status == 3) {
                  // allow swipe-to-delete only on completed games
                  return Dismissible(
                    key: ValueKey(game['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteGame(game['id']),
                    child: tile,
                  );
                }

                return tile;
              },
            ),
    );
  }

  void _showAiDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select AI Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['random', 'perfect', 'oneship']
              .map((level) => ListTile(
                    title: Text(level),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SetupGamePage(aiLevel: level),
                        ),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
