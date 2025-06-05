class ShipGame {
  final int id;
  final String playerA;
  final String playerB;
  final int position;
  final int status;
  final int turn;
  final List<String> shipPositions;
  final List<String> wreckPositions;
  final List<String> sunkPositions;
  final List<String> shotPositions;

  ShipGame({
    required this.id,
    required this.playerA,
    required this.playerB,
    required this.position,
    required this.status,
    required this.turn,
    required this.shipPositions,
    required this.wreckPositions,
    required this.sunkPositions,
    required this.shotPositions,
  });

  factory ShipGame.fromJson(Map<String, dynamic> json) {
    return ShipGame(
      id: json['id'],
      playerA: json['player1'] ?? '',
      playerB: json['player2'] ?? '',
      position: json['position'],
      status: json['status'],
      turn: json['turn'],
      shipPositions: List<String>.from(json['ships'] ?? []),
      wreckPositions: List<String>.from(json['wrecks'] ?? []),
      sunkPositions: List<String>.from(json['sunk'] ?? []),
      shotPositions: List<String>.from(json['shots'] ?? []),
    );
  }
}
