import 'dart:math';
import 'matrices.dart';

class Network{
  List<int> layers = [];
  List<Matrix> weights = [];
  List<Matrix?> biases = [];
  List<Matrix?> preActivated = [];

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
    //weights[0].display();
  }

  double reLU(double x){
    return max(0, x);
  }

  double reLUDerivative(double x){
    return (x > 0) ? 1 : 0;
  }

  double tanH(double x){
    double value = exp(2*x);
    return (value-1)/(value+1);
  }

  double tanHDerivative(double x){
    return 1-pow(tanH(x), 2).toDouble();
  }

  double sigmoid(double x){
    return 1/1+exp(-x);
  }

  double sigmoidDerivative(double x){
    return sigmoid(x) * (1-sigmoid(x));
  }

  void update(Matrix dCdW, int layer){
    for(int i = 0; i < weights[layer].row; i++){
      for(int j = 0; j < weights[layer].col; j++){
        double current = weights[layer].getAt(row: i, col: j);
        current = current - dCdW.getAt(row: 0, col: i);
        weights[layer].setAt(row: i, col: j, value: current);
      }
    }
  }

  void display(){
    for(int x = 0; x < weights.length; x++){
      weights[x].display();
      print("");
    }
    print("Done.");
  }

  Matrix? forwardPass(Matrix input, List<double Function(double)> functions){
    preActivated.add(input);
    print("Running Forwardpass");
    Matrix? matrix;

    for(int i=0; i<weights.length; i++){
      if(i==0){
        matrix = input.dot(weights[i]);
      }
      else{
        matrix = matrix?.dot(weights[i]);
      }
      matrix = matrix?.add(biases[i]!);
      preActivated.add(matrix);
      matrix = matrix?.performFunction(functions[i]);
    }
    print("Done.");
    return matrix;
  }

  double mse(Matrix trueValues, Matrix predictedValues){
    List<dynamic>? trueNums = trueValues.getRow(0);
    List<dynamic>? predictedNums = predictedValues.getRow(0);

    List<num> result = [];

    for (int i = 0; i < trueNums!.length; i++) {
      result.add(pow(trueNums[i] - predictedNums?[i], 2));
    }

    num sum = result.reduce((value, element) => value + element);

    return (sum/result.length).toDouble();
  }

  double mseDerivative(Matrix trueValues, Matrix predictedValues){
    List<dynamic>? trueNums = trueValues.getRow(0);
    List<dynamic>? predictedNums = predictedValues.getRow(0);

    List<num> result = [];

    for (int i = 0; i < trueNums!.length; i++) {
      result.add((trueNums[i] - predictedNums?[i])*2);
    }

    num sum = result.reduce((value, element) => value + element);

    return (sum/result.length).toDouble();
  }

  double Function(double)? getDerivative(double Function(double) function){
    if(function == tanH){
      return tanHDerivative;
    }
    if(function == reLU){
      return reLUDerivative;
    }
    if(function == mse){
      return reLUDerivative;
    }
    if(function == sigmoid){
      return sigmoidDerivative;
    }
    else{
      return null;
    }
  }

  void backwardsPass(Matrix expected, Matrix predicted, List<double Function(double)> functions, double lr){
    print("Running backprop.");
    expected.display();
    predicted.display();

    for(int i = weights.length-1; i>=0; i--){
      print("Updating Layer:${i}");
      double dCdY = 0;
      if(i==weights.length-1){
        dCdY = mseDerivative(predicted, expected);
      }
      else{
        Matrix output = expected;
        for(int x = weights.length-1; x >= i; x--){
          output = output.performFunction(getDerivative(functions[x])!);
          output = output.subtract(biases[x]!)!;
          output = output.dot(weights[x].transpose()!)!;
        }
        dCdY = mseDerivative(preActivated[i]!.performFunction(functions[i]), output);
      }
      Matrix dYdZ = preActivated[i]!;
      dYdZ = dYdZ.performFunction(functions[i]);
      Matrix a=preActivated[i]!;
      Matrix dCdW = dYdZ.multiplyByNumber(dCdY)!.multiply(a)!.multiplyByNumber(0.01)!;
      update(dCdW, i);
    }
    print("Done.");
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
  Network network = new Network(layers: [1, 1, 1, 1]);
  List<double Function(double)> functions = [network.reLU, network.reLU, network.sigmoid];

  Matrix input = new Matrix(row: 1, col: 1);
  input.empty();

  Matrix expected = new Matrix(row: 1, col: 1);
  expected.empty();
  expected.setAt(row: 0, col: 0, value: 1);
  //expected = [1.0]

  Matrix? predicted = network.forwardPass(input, functions);
  predicted!.display();

  network.backwardsPass(expected, predicted, functions, 0.01);
  network.backwardsPass(expected, predicted, functions, 0.01);
  network.backwardsPass(expected, predicted, functions, 0.01);

  predicted = network.forwardPass(input, functions);
  predicted?.display();
}