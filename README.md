# tictactoe2

tictactoe

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Issue
To reproduce issues with the neural network.
1. Run the program on web
2. select VS AI
3. The output begins in initialisation where the weights are displayed
4. **The output is also displayed on the web console when pressing f12**
5. Once a move is made the program runs forward propagation using the state of the board as an input to make a prediction.
6. Then the player move is used to perform backpropagation and update the weights and biases.
7. the neural network then makes a new move by running forward propagation.
8. it displays its output to the console.
9. If you want more details on the weights, adding weights[i].display(); in the backwardsPass loop will display it on the screen.

Previously when I ran the program, all of the weights would converge to the same number. 
I updated the backpropagation to function correctly. 
Now it seems to be modifying the weights in a specific direction little by little. 
However the result is always the same.
