import 'package:flutter/material.dart';
import 'package:tictactoe2/pages/AIPage.dart';
import 'package:tictactoe2/pages/CompPage.dart';
import 'package:tictactoe2/pages/TwoPlayerPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> choices = ['Two Player', 'VS Comp', 'VS AI'];
  int choiceIndex = 0;

  void backwardPressed() {
    setState(() {
      if(choiceIndex == 0){
        choiceIndex = choices.length-1;
      }
      else{
        choiceIndex--;
      }
    });
  }
  void forwardPressed() {
    setState(() {
      choiceIndex = (choiceIndex + 1) % choices.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff181818),
      body: Column(
        children: [
          Center(
              child: const Image(
                  image: AssetImage('../Assets/Logo.png'),
                  width: 400,
                  height: 400)),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 200, 0, 20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () => backwardPressed(),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0x559B915C);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: const Text("<", style: TextStyle(color: Color(0xffCFCFCF), fontSize: 100))),
                  Container(
                    width: 500,
                    child: Center(
                      child: Text(choices[choiceIndex],
                          style:
                              const TextStyle(color: Color(0xffbfbfbf), fontSize: 100)),
                    ),
                  ),
                  TextButton(
                      onPressed: () => forwardPressed(),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0x559B915C);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: const Text(">", style: TextStyle(color: Color(0xffCFCFCF), fontSize: 100)))
                ],
              ),
            ),
          ),
          Center(
            child: TextButton(
                onPressed: () {
                  if(choiceIndex == 0){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TwoPlayer()));
                  }
                  else if(choiceIndex == 1){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CompGame()));
                  }
                  else{
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NeuralNetwork()));
                  }
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered)) {
                        return const Color(0x559B915C);
                      }
                      return null;
                    },
                  ),
                ),
                child: const Text("New Game", style: TextStyle(color: Color(0xffCFCFCF), fontSize: 100))),
          )
        ],
      ),
    );
  }
}
