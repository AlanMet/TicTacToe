import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Libs/matrices.dart';
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
    functions = [network.reLU, network.reLU, network.sigmoid];
    super.initState();
  }

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

  Matrix encodeMove(int index){
    Matrix boardMatrix = Matrix(row: 1, col: 9);
    boardMatrix.empty();
    if(board[index] == "X"){
      boardMatrix.setAt(row: 0, col: index, value: 1);
    }
    if(board[index] == "O"){
      boardMatrix.setAt(row: 0, col: index, value: 1);
    }
    return boardMatrix;
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

  void makeMove(int index) {
    print("Making move");
    if (waiting == false) {
      setState(() {
        Matrix predicted = network.forwardPass(encodeBoard(), functions)!;
        if (board[index] == '') {
          if (xTurn) {
            board[index] = 'X';
          } else {
            board[index] = 'O';
          }
          Matrix expected = encodeMove(index);
          xTurn = !xTurn;
          bool won = checkWin();
          if(!won){
            makeAIMove(predicted, expected);
          }
        }
      });
    }
  }

  void makeAIMove(Matrix predicted, Matrix expected){
    network.backwardsPass(expected, predicted, functions, 0.01);
    Matrix move = network.forwardPass(encodeBoard(), functions)!;
    move.display();
    int index = getMove(move);
    while(board[index] != ''){
      print("Index modified");
      index= (index+1)%9;
    }
    print(index);
    setState(() {
      if (board[index] == '') {
        if (xTurn) {
          board[index] = 'X';
        } else {
          board[index] = 'O';
        }
        xTurn = !xTurn;
        bool won = checkWin();
      }
    });
  }

  int getMove(Matrix move){
    List<dynamic>? output = move.getRow(0);

    int index = 0;
    double closest = double.infinity;

    for (int i = 0; i < output!.length; i++) {
      if (output[i] > closest) {
        index = i;
        closest = output[i];
      }
    }
    return index;
  }


  bool checkWin() {
    //horizontal check
    if (board[0] == board[1] && board[0] == board[2] && board[0] != '') {
      showWinDialogue(board[0]);
      return true;
    } else if (board[3] == board[4] &&
        board[3] == board[5] &&
        board[3] != '') {
      showWinDialogue(board[3]);
      return true;
    }
    else if (board[6] == board[7] && board[6] == board[8] && board[6] != '') {
      showWinDialogue(board[6]);
      return true;
    }
    //vertical check
    else if (board[0] == board[3] && board[0] == board[6] && board[0] != '') {
      showWinDialogue(board[0]);
      return true;
    }
    else if (board[1] == board[4] && board[1] == board[7] && board[1] != '') {
      showWinDialogue(board[1]);
      return true;
    }
    else if (board[2] == board[5] && board[2] == board[8] && board[2] != '') {
      showWinDialogue(board[2]);
      return true;
    }
    //diagonal check
    else if (board[0] == board[4] && board[0] == board[8] && board[0] != '') {
      showWinDialogue(board[0]);
      return true;
    }
    else if (board[2] == board[4] && board[4] == board[6] && board[2] != '') {
      showWinDialogue(board[2]);
      return true;
    }
    else if(!board.contains('')){
      showWinDialogue(null);
      return true;
    }
    return false;
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
