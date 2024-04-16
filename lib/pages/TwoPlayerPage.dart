import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TwoPlayer extends StatefulWidget {
  const TwoPlayer({super.key});

  @override
  State<TwoPlayer> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TwoPlayer> {
  int playerOneScore = 0;
  int playerTwoScore = 0;

  bool waiting = false;
  bool xTurn = true;
  bool xStart = true;

  List<String> board = ['', '', '', '', '', '', '', '', ''];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff181818),
      body: Column(
        children: [
          Center(
            child: Text(getScore(),
                style: TextStyle(color: Color(0xffbfbfbf), fontSize: 25)),
          ),
          Container(
            width: 850,
            height: 850,
            child: GridView.builder(
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => makeMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xff9B915C), width: 1)),
                      child: Center(
                        child: Text(board[index],
                            style: TextStyle(color: Color(0xffbfbfbf), fontSize: 100)),
                      ),
                    ),
                  );
                }),
          ),
          Center(
            child: Text(
              "Turn: ${getPlayer()}",
              style: TextStyle(color: Color(0xffbfbfbf), fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }

  String getPlayer() {
    if (xTurn) {
      return 'X';
    } else {
      return 'O';
    }
  }

  String getScore() {
    return "${playerOneScore} - ${playerTwoScore}";
  }

  void makeMove(int index) {
    if (waiting == false) {
      setState(() {
        if (board[index] == '') {
          if (xTurn) {
            board[index] = 'X';
          } else {
            board[index] = 'O';
          }
          xTurn = !xTurn;
          checkWin();
        }
      });
    }
  }

  void checkWin() {
      //horizontal check
      if (board[0] == board[1] && board[0] == board[2] && board[0] != '') {
        showWinDialogue(board[0]);
      } else if (board[3] == board[4] &&
          board[3] == board[5] &&
          board[3] != '') {
        showWinDialogue(board[3]);
      }
      else if (board[6] == board[7] && board[6] == board[8] && board[6] != '') {
        showWinDialogue(board[6]);
      }
      //vertical check
      else if (board[0] == board[3] && board[0] == board[6] && board[0] != '') {
        showWinDialogue(board[0]);
      }
      else if (board[1] == board[4] && board[1] == board[7] && board[1] != '') {
        showWinDialogue(board[1]);
      }
      else if (board[2] == board[5] && board[2] == board[8] && board[2] != '') {
        showWinDialogue(board[2]);
      }
      //diagonal check
      else if (board[0] == board[4] && board[0] == board[8] && board[0] != '') {
        showWinDialogue(board[0]);
      }
      else if (board[2] == board[4] && board[4] == board[6] && board[2] != '') {
        showWinDialogue(board[2]);
      }
      else if(!board.contains('')){
        showWinDialogue(null);
      }
  }

  void showWinDialogue(String? winner) {
    resetboard(winner);
    xTurn = true;
    if (winner == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text("Tie!"));
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Winner: $winner"),
            );
          });
    }
  }

  void resetboard(String? winner) {
    waiting = true;
    Timer(const Duration(seconds: 3), () {
      setState(() {
        board = ['', '', '', '', '', '', '', '', ''];
        if (xStart) {
          xStart = !xStart;
          xTurn = false;
        }
        if (winner == 'X') {
          playerOneScore += 1;
        } else if (winner == 'O') {
          playerTwoScore += 1;
        }
      });
      waiting = false;
    });
  }
}
