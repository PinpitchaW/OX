import 'package:flutter/material.dart';

void main() {
  runApp(OX());
}

class OX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChooseMode(),
    );
  }
}

class ChooseMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraphicMode(),
                  ),
                );
              },
              child: Text('Graphic Mode'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextMode(),
                  ),
                );
              },
              child: Text('Text Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class Board {
  List<List<String>> _board = List.generate(3, (_) => List.filled(3, ''));
  String _currentPlayer = 'X';
  String get currentPlayer => _currentPlayer;

  List<List<String>> get board => _board;

  void makeMove(int row, int col) {
    if (_board[row][col].isEmpty) {
      _board[row][col] = _currentPlayer;
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    }
  }

  static bool checkWinner(List<List<String>> board) {
    for (int i = 0; i < 3; i++) {
      //row
      if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0].isNotEmpty) {
        return true;
      }
      //column
      if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i].isNotEmpty) {
        return true;
      }
    }
    //diagonal
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0].isNotEmpty) {
      return true;
    }
    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2].isNotEmpty) {
      return true;
    }
    return false;
  }

  static bool drawCheck(List<List<String>> board) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          return false;
        }
      }
    }
    if (Board.checkWinner(board)){
      return false;
    }
    return true;
  }
}

class GraphicMode extends StatefulWidget {
  @override
  _GraphicModeState createState() => _GraphicModeState();
}

class _GraphicModeState extends State<GraphicMode> {
  Board _board = Board();

  void restartGame() {
    setState(() {
      _board = Board();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphic Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 3; j++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _board.makeMove(i, j);
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Center(
                          child: Text(
                            _board.board[i][j],
                            style: TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            Text('Current Player: ${_board.currentPlayer}'),
            SizedBox(height: 20),
            if (Board.checkWinner(_board.board))
              Text('Winner: ${_board.currentPlayer == 'X' ? 'O' : 'X'}'),
            if (Board.drawCheck(_board.board))
              Text('It\'s a Draw!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartGame,
              child: Text('Restart Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextMode extends StatefulWidget {
  @override
  _TextModeState createState() => _TextModeState();
}

class _TextModeState extends State<TextMode> {
  Board _board = Board();
  TextEditingController _controller = TextEditingController();
  List<List<String>> initBoard = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  void moveMake() {
    String moveText = _controller.text.trim();
    if (moveText.toLowerCase() == 'r') {
      restartGame();
    } else {
      int? move = int.tryParse(moveText);
      if (move != null && move >= 1 && move <= 9) {
        int row = (move - 1) ~/ 3;
        int col = (move - 1) % 3;
        setState(() {
          _board.makeMove(row, col);
          updateinitBoard();
          _controller.clear();
        });
      } else {
        print('Cannot read: $moveText');
      }
    }
  }

  void restartGame() {
    setState(() {
      _board = Board();
      updateinitBoard();
    });
  }

  void updateinitBoard() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        initBoard[i][j] = _board.board[i][j].isEmpty ? '${i * 3 + j + 1}' : _board.board[i][j];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Mode'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Current Player: ${_board.currentPlayer}'),
          SizedBox(height: 20),
          if (Board.checkWinner(_board.board))
            Text('Winner: ${_board.currentPlayer == 'X' ? 'O' : 'X'}'),
          if (Board.drawCheck(_board.board))
            Text('Draw!'),
          SizedBox(height: 20),
          Text(
                ' ${initBoard[0][0]} | ${initBoard[0][1]} | ${initBoard[0][2]}\n' +
                ' ${initBoard[1][0]} | ${initBoard[1][1]} | ${initBoard[1][2]}\n' +
                ' ${initBoard[2][0]} | ${initBoard[2][1]} | ${initBoard[2][2]}',
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(height: 10),
          Text('Enter your number (1-9)'),
          Text('Press "r" to restart'),
          Container(
            width : 400,
            height: 100,
            padding: EdgeInsets.all(10.0),
            child : TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onSubmitted: (value) {
              moveMake();
            },
          ),
          ),
        ],
      ),
    );
  }
}
