import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tictactoe2/Libs/matrices.dart';

import '../Libs/networks.dart';


class NeuralNetwork extends StatefulWidget {
  const NeuralNetwork({super.key});

  @override
  State<NeuralNetwork> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<NeuralNetwork> {
  int playerOneScore = 0;
  int playerTwoScore = 0;

  bool waiting = false;
  bool xTurn = true;
  bool xStart = true;

  List<String> board = ['', '', '', '', '', '', '', '', ''];
  late Matrix boardState;
  late Network network;
  late List<double Function(double)> functions;

  @override
  void initState() {
    network = Network(layers: [9, 6, 6, 9]);
    functions = [network.reLU, network.reLU, network.tanH];
    boardState = encodeBoard();
    boardState.display();
    super.initState();
  }

  Matrix encodeBoard(){
    Matrix boardMatrix = Matrix(row: 1, col: 9);
    boardMatrix.empty();

    for(int x = 0; x < boardMatrix.col; x++){
      if(board[x] == "X"){
        boardMatrix.setAt(row: 0, col: x, value: 1);
      }
      if(board[x] == "O"){
        boardMatrix.setAt(row: 0, col: x, value: -1);
      }
    }

    return boardMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      body: Column(
        children: [
          Center(
            child: Text(getScore(),
                style: const TextStyle(color: Color(0xffbfbfbf), fontSize: 25)),
          ),
          SizedBox(
            width: 850,
            height: 850,
            child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => makeMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: const Color(0xff9B915C), width: 1)),
                      child: Center(
                        child: Text(board[index],
                            style: const TextStyle(color: Color(0xffbfbfbf), fontSize: 100)),
                      ),
                    ),
                  );
                }),
          ),
          Center(
            child: Text(
              "Turn: ${getPlayer()}",
              style: const TextStyle(color: Color(0xffbfbfbf), fontSize: 25),
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
        Matrix? prediction = network.forwardPass(boardState, functions);
        print("Predicted move: ");
        prediction?.display();
        if (board[index] == '') {
          if (xTurn) {
            board[index] = 'X';
          } else {
            board[index] = 'O';
          }
          xTurn = !xTurn;
          checkWin();
          boardState = encodeBoard();
          boardState.display();
          makeAIMove(prediction!);
        }
      });
    }
  }

  void makeAIMove(Matrix prediction){
    print("AI making move");
    network.backwardsPass(prediction, boardState);
    int index = network.getAnswer(boardState, functions, -1);
    while(board[index] != ''){
      index= (index+1)%9;
    }
    print("Index: ${index}");
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
    boardState = encodeBoard();
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
