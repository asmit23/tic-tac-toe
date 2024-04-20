import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          backgroundColor:
              const Color(0xFFD2B48C), // Use a wooden color for background
          // You can adjust other colors as needed
        ),
      ),
      home: TicTacToeHomeScreen(),
    );
  }
}

class TicTacToeHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .colorScheme
          .background, // Use theme background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tic Tac Toe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text color
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TicTacToeScreen(singlePlayer: true)),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white, // Use blue button text color
              ),
              child: Text('Single Player'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TicTacToeScreen(singlePlayer: false)),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white, // Use blue button text color
              ),
              child: Text('Two Players'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  final bool singlePlayer;

  const TicTacToeScreen({Key? key, required this.singlePlayer})
      : super(key: key);

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  // Add TickerProviderStateMixin
  late List<List<String>> _board;
  late String _currentPlayer;
  late bool _gameStarted;
  late bool _gameOver;
  late int _playerXScore;
  late int _playerOScore;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeBoard() {
    _board = List.generate(3, (_) => List.generate(3, (_) => ''));
    _currentPlayer = 'X';
    _gameStarted = true;
    _gameOver = false;
    _playerXScore = 0;
    _playerOScore = 0;
    if (widget.singlePlayer && _currentPlayer == 'O') {
      _makeRandomMoveAfterDelay();
    }
  }

  void _makeMove(int row, int col) {
    if (!_gameOver && _board[row][col] == '') {
      setState(() {
        _board[row][col] = _currentPlayer;
        String? winner = _checkWinner(row, col);
        if (winner != null) {
          _gameOver = true;
          if (winner == 'X') {
            _playerXScore++;
            _showDialog('$winner wins!');
          } else if (winner == 'O') {
            _playerOScore++;
            _showDialog('$winner wins!');
          }
        } else if (_checkDraw()) {
          _gameOver = true;
          _showDialog('It\'s a draw!');
        } else {
          _currentPlayer = (_currentPlayer == 'X') ? 'O' : 'X';
          if (widget.singlePlayer && _currentPlayer == 'O') {
            _makeRandomMoveAfterDelay();
          }
        }
      });
    }
  }

  void _makeRandomMoveAfterDelay() {
    Timer(Duration(seconds: 2), () {
      _makeRandomMove();
    });
  }

  void _makeRandomMove() {
    List<int> emptyCells = [];
    for (int i = 0; i < _board.length; i++) {
      for (int j = 0; j < _board[i].length; j++) {
        if (_board[i][j] == '') {
          emptyCells.add(i * _board.length + j);
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      int index = Random().nextInt(emptyCells.length);
      int row = emptyCells[index] ~/ _board.length;
      int col = emptyCells[index] % _board.length;
      _makeMove(row, col);
      _controller.forward(from: 0.0); // Trigger animation
    }
  }

  String? _checkWinner(int row, int col) {
    // Check row
    if (_board[row][0] == _board[row][1] && _board[row][1] == _board[row][2]) {
      if (_board[row][0] != '') return _board[row][0];
    }
    // Check column
    if (_board[0][col] == _board[1][col] && _board[1][col] == _board[2][col]) {
      if (_board[0][col] != '') return _board[0][col];
    }
    // Check diagonals
    if (row == col) {
      if (_board[0][0] == _board[1][1] &&
          _board[1][1] == _board[2][2] &&
          _board[0][0] != '') return _board[0][0];
    }
    if (row + col == 2) {
      if (_board[0][2] == _board[1][1] &&
          _board[1][1] == _board[2][0] &&
          _board[0][2] != '') return _board[0][2];
    }
    return null;
  }

  bool _checkDraw() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == '') return false;
      }
    }
    return true;
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeBoard(); // Start new game
              });
            },
            child: Text('New Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    return GestureDetector(
      onTap: () {
        if (!_gameOver && _board[row][col] == '') {
          _makeMove(row, col);
        }
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          width: 100, // Adjust cell width
          height: 100, // Adjust cell height
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black), // Use black border
            color: Theme.of(context).colorScheme.primary, // Use primary color
          ),
          child: Center(
            child: _board[row][col] == 'X'
                ? Icon(Icons.close,
                    size: 40,
                    color: Colors.black) // Cross for player X with black color
                : (_board[row][col] == 'O'
                    ? Icon(Icons.circle,
                        size: 40,
                        color: Colors
                            .black) // Circle for player O with black color
                    : null),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      backgroundColor: Theme.of(context)
          .colorScheme
          .background, // Use theme background color
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Player X',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Score: $_playerXScore',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Player O',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Score: $_playerOScore',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCell(0, 0),
              _buildCell(0, 1),
              _buildCell(0, 2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCell(1, 0),
              _buildCell(1, 1),
              _buildCell(1, 2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCell(2, 0),
              _buildCell(2, 1),
              _buildCell(2, 2),
            ],
          ),
        ],
      ),
    );
  }
}
