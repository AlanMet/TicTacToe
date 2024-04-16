import 'dart:math';
import 'matrices.dart';

class Network{
  List<int> layers = [];
  List<Matrix> weights = [];
  List<Matrix?> biases = [];

  Network({required this.layers}){
    initParams();
    //display();
  }

  void initParams(){
    for(int x = 0; x < layers.length-1; x++){
      Matrix matrix = Matrix(row: layers[x], col: layers[x+1]);
      matrix.generate(-1, 1);
      //matrix.display();
      //print("");
      weights.add(matrix);

      matrix = Matrix(row: 1, col: layers[x+1]);
      matrix.generate(-1, 1);
      biases.add(matrix);
    }
    weights[0].display();
  }

  double reLU(double x){
    return max(0, x);
  }

  double update(double MSE, double x){
    return MSE * x;
  }

  double tanH(double x){
    double value = exp(2*x);
    return (value-1)/(value+1);
  }

  void display(){
    for(int x = 0; x < weights.length; x++){
      weights[x].display();
      print("");
    }
    print("Done.");
  }

  Matrix? forwardPass(Matrix input, List<double Function(double)> functions){
    print("Running");
    Matrix? matrix;

    for(int i=0; i<weights.length; i++){
      if(i==0){
        matrix = input.dot(weights[i]);
      }
      else{
        matrix = matrix?.dot(weights[i]);
      }
      matrix = matrix?.add(biases[i]!);
      matrix = matrix?.performFunction(functions[i]);
    }
    print("Done.");
    return matrix;
  }

  double getMSE(Matrix trueValues, Matrix predictedValues){
    List<dynamic>? trueNums = trueValues.getRow(0);
    List<dynamic>? predictedNums = predictedValues.getRow(0);

    List<num> result = [];

    for (int i = 0; i < trueNums!.length; i++) {
      result.add(pow(trueNums[i] - predictedNums?[i], 2));
    }

    num sum = result.reduce((value, element) => value + element);

    return (sum/result.length).toDouble();
  }

  void backwardsPass(Matrix input, Matrix output){
    print("Running");
    Matrix? matrix;
    double MSE = getMSE(input, output);
    //print(MSE);

    for(int i = 0; i < biases.length; i++){
      biases[i] = biases[i]?.performFunction((double x) => x*MSE);
      weights[i] = weights[i].performFunction((double x) => x*MSE);
    }
    weights[0].display();

  }

  int getAnswer(Matrix input, List<double Function(double)> functions, int player){
    Matrix? matrix = forwardPass(input, functions);

    List<dynamic>? output = matrix?.getRow(0);

    int index = 0;
    double closest = double.infinity;

    for (int i = 0; i < output!.length; i++) {
      double difference = (output[i] - player).abs();
      if (difference < closest) {
        index = i;
        closest = difference;
      }
    }
    return index;
  }
}

void main(){
  Network network = new Network(layers: [9, 6, 6, 9]);

  Matrix input = new Matrix(row: 1, col: 9);
  input.empty();
  input.setAt(row: 0, col: 0, value: 1);

  List<double Function(double)> functions = [network.reLU, network.reLU, network.tanH];
  Matrix? forward = network.forwardPass(input, functions);

  for(int x = 0; x< 1000; x++){
    Matrix predicted = new Matrix(row: 1, col: 9);
    predicted.empty();
    predicted.setAt(row: 0, col: 1, value: -1);

    network.backwardsPass(forward!, predicted);

    forward = network.forwardPass(input, functions);
    forward?.display();

  }
}