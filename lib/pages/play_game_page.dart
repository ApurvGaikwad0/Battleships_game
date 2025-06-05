import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/game_model.dart';
import '../constants.dart';

class PlayGamePage extends StatefulWidget {
  final int gameId;
  const PlayGamePage({super.key, required this.gameId});

  @override
  State<PlayGamePage> createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  ShipGame? _game;
  bool _loading = true;
  bool _submitting = false;
  String? _selectedCoord;
  final _service = GameService();

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final res = await _service.fetchGame(widget.gameId);
    if (res.statusCode == 200) {
      final data = ShipGame.fromJson(jsonDecode(res.body));
      setState(() {
        _game = data;
        _loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading game')),
      );
    }
  }

  bool get _canShoot =>
      _game != null && _game!.status == 3 && _game!.turn == _game!.position;

  Future<void> _shoot() async {
    if (!_canShoot || _selectedCoord == null || _submitting) return;
    setState(() => _submitting = true);
    final res = await _service.shoot(widget.gameId, _selectedCoord!);
    setState(() => _selectedCoord = null);

    if (res.statusCode == 200) {
      final result = jsonDecode(res.body);
      final sunk = result['sunk_ship'] as bool;
      final won = result['won'] as bool;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sunk ? 'Ship sunk!' : 'Missed!')),
      );
      if (won) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Victory!'),
            content: const Text('You have won the game.'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/games')),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        await _loadGame();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error shooting')),
      );
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play Game')),
      body: _loading || _game == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: kBoardSize,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: kBoardSize * kBoardSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ kBoardSize;
                      final col = index % kBoardSize;
                      if (row == 0 && col == 0) return const SizedBox();
                      if (row == 0) {
                        return Center(child: Text('$col'));
                      }
                      if (col == 0) {
                        return Center(
                            child: Text(String.fromCharCode(64 + row)));
                      }
                      final coord = '${String.fromCharCode(64 + row)}$col';
                      final ships = _game!.shipPositions;
                      final wrecks = _game!.wreckPositions;
                      final sunk = _game!.sunkPositions;
                      final shots = _game!.shotPositions;
                      final overlays = <Widget>[];

                      if (ships.contains(coord)) {
                        overlays.add(const Positioned(
                          top: 2,
                          left: 2,
                          child: Icon(
                            Icons.directions_boat_outlined,
                            size: 20,
                            color: Colors.tealAccent,
                          ),
                        ));
                      }
                      if (wrecks.contains(coord)) {
                        overlays.add(const Positioned(
                          bottom: 2,
                          left: 2,
                          child: Icon(
                            Icons.water_damage,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ));
                      }
                      if (sunk.contains(coord)) {
                        overlays.add(const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.anchor,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ));
                      }
                      if (shots.contains(coord) && !sunk.contains(coord)) {
                        overlays.add(const Positioned(
                          bottom: 2,
                          right: 2,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white54,
                          ),
                        ));
                      }

                      return GestureDetector(
                        onTap: () {
                          if (_canShoot &&
                              !shots.contains(coord) &&
                              !sunk.contains(coord)) {
                            setState(() => _selectedCoord = coord);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: coord == _selectedCoord
                                ? Colors.teal.withOpacity(0.3)
                                : null,
                            border: Border.all(color: Colors.teal),
                          ),
                          child: Stack(children: overlays),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: _canShoot && !_submitting ? _shoot : null,
                    child: _submitting
                        ? const CircularProgressIndicator()
                        : const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text('Fire'),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
