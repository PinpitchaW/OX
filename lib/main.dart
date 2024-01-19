import 'dart:async';
import 'dart:html' as html;
import 'dart:convert' as html;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  bool checkWinner(List<List<String>> board) {
    for (int i = 0; i < 3; i++) {
      // row
      if (board[i][0] == board[i][1] &&
          board[i][1] == board[i][2] &&
          board[i][0].isNotEmpty) {
        return true;
      }
      // column
      if (board[0][i] == board[1][i] &&
          board[1][i] == board[2][i] &&
          board[0][i].isNotEmpty) {
        return true;
      }
    }
    // diagonal
    if (board[0][0] == board[1][1] &&
        board[1][1] == board[2][2] &&
        board[0][0].isNotEmpty) {
      return true;
    }
    if (board[0][2] == board[1][1] &&
        board[1][1] == board[2][0] &&
        board[0][2].isNotEmpty) {
      return true;
    }
    return false;
  }

  bool drawCheck(List<List<String>> board) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          return false;
        }
      }
    }
    if (checkWinner(board)) {
      return false;
    }
    return true;
  }


  Future<void> saveGame() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/game_data.txt');

    String data = 'currentPlayer:$_currentPlayer\n';

    for (int i = 0; i < 3; i++) {
      data += 'row_$i:${_board[i].join(',')}\n';
    }

    await file.writeAsString(data);

    print('Game saved successfully');
  } catch (e) {
    print('Error saving game: $e');
  }
}


  Future<bool> loadGame() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/game_data.txt');

      if (!file.existsSync()) {
        print('No saved game found');
        return false;
      }

      String data = await file.readAsString();

      List<String> lines = data.split('\n');

      _currentPlayer = lines[0].split(':')[1];

      for (int i = 1; i <= 3; i++) {
        _board[i - 1] = lines[i].split(':')[1].split(',');
      }

      print('Game loaded successfully');
      return true;
    } catch (e) {
      print('Error loading game: $e');
      return false;
    }
  }

  Future<void> saveGameWeb() async {
    try {
      String text = 'currentPlayer:$_currentPlayer\n';
      for (int i = 0; i < 3; i++) {
        text += 'row_$i:${_board[i].join(',')}\n';
      }

      final bytes = html.Utf8Encoder().convert(text);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..style.display = 'none'
        ..download = 'game_data.txt';

      html.document.body?.children.add(anchor);

      anchor.click();

      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      print('Game saved successfully (web)');
    } catch (e) {
      print('Error saving game (web): $e');
    }
  }

  Future<bool> loadGameWeb() async {
  try {
    final html.InputElement uploadInput = html.FileUploadInputElement() as html.InputElement;
    uploadInput.click();

    final completer = Completer<String>();

    uploadInput.onChange.listen((e) {
      final html.File file = (uploadInput.files as List<html.File>)!.first;
      final html.FileReader reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        completer.complete(reader.result as String);
      });

      reader.readAsText(file);
    });

    uploadInput.click(); 

    final String data = await completer.future;

    List<String> lines = data.split('\n');

    _currentPlayer = lines[0].split(':')[1];

    for (int i = 1; i <= 3; i++) {
      _board[i - 1] = lines[i].split(':')[1].split(',');
    }

    print('Game loaded successfully (web)');
    return true;
  } catch (e) {
    print('Error loading game (web): $e');
    return false;
  }
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

  void saveGame() {
    kIsWeb ? _board.saveGameWeb() : _board.saveGame();
  }

  void loadGame() {
    kIsWeb ? _board.loadGameWeb() : _board.loadGame();
    setState(() {});
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
            if (_board.checkWinner(_board.board))
              Text('Winner: ${_board.currentPlayer == 'X' ? 'O' : 'X'}'),
            if (_board.drawCheck(_board.board)) Text('Draw!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartGame,
              child: Text('Restart Game'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveGame,
              child: Text('Save Game'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadGame,
              child: Text('Load Game'),
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

  void moveMake() async {
    String moveText = _controller.text.trim();
    if (moveText.toLowerCase() == 'r') {
      restartGame();
    } else if (moveText.toLowerCase() == 's') {
      saveGame();
    } else if (moveText.toLowerCase() == 'l') {
      loadGame();
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
        initBoard[i][j] = _board.board[i][j].isEmpty
            ? '${i * 3 + j + 1}'
            : _board.board[i][j];
      }
    }
  }

  void saveGame() {
    kIsWeb ? _board.saveGameWeb() : _board.saveGame();
  }

  void loadGame() {
    kIsWeb ? _board.loadGameWeb() : _board.loadGame();
    updateinitBoard();
    setState(() {});
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
          if (_board.checkWinner(_board.board))
            Text('Winner: ${_board.currentPlayer == 'X' ? 'O' : 'X'}'),
          if (_board.drawCheck(_board.board)) Text('Draw!'),
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
          Text('Press "s" to save'),
          Text('Press "l" to load'),
          Container(
            width: 400,
            height: 100,
            padding: EdgeInsets.all(10.0),
            child: TextField(
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
