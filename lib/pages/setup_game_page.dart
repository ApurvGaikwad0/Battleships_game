import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../constants.dart';

class SetupGamePage extends StatefulWidget {
  final String? aiLevel;
  const SetupGamePage({super.key, this.aiLevel});

  @override
  State<SetupGamePage> createState() => _SetupGamePageState();
}

class _SetupGamePageState extends State<SetupGamePage> {
  late List<bool> _selected;
  final List<String> _shipCoords = [];
  bool _submitting = false;
  final _service = GameService();

  @override
  void initState() {
    super.initState();
    _selected = List.generate(kBoardSize * kBoardSize, (_) => false);
  }

  String _coordFromIndex(int idx) {
    final row = idx ~/ kBoardSize;
    final col = idx % kBoardSize;
    return '${String.fromCharCode(64 + row)}$col';
  }

  void _toggleCell(int index) {
    final row = index ~/ kBoardSize;
    final col = index % kBoardSize;
    if (row == 0 || col == 0) return;

    setState(() {
      if (_selected[index]) {
        _selected[index] = false;
        _shipCoords.remove(_coordFromIndex(index));
      } else if (_shipCoords.length < kMaxShips) {
        _selected[index] = true;
        _shipCoords.add(_coordFromIndex(index));
      }
    });
  }

  Future<void> _submit() async {
    if (_shipCoords.length != kMaxShips) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Select exactly $kMaxShips positions before proceeding.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final res = await _service.createGame(_shipCoords, widget.aiLevel);
    setState(() => _submitting = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game created!')),
      );
      Navigator.pushReplacementNamed(context, '/games');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create game')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Ships')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  return Center(child: Text(String.fromCharCode(64 + row)));
                }
                return GestureDetector(
                  onTap: () => _toggleCell(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selected[index]
                          ? Colors.teal.withOpacity(0.3)
                          : null,
                      border: Border.all(color: Colors.teal),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CircularProgressIndicator()
                  : const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Create Game'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
