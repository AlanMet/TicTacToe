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
      matrix.display();
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

  double update(double x, double lr, double dCdW){
    return x - lr*(dCdW);
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
        preActivated.add(null);
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
    else{
      return null;
    }
  }

  void backwardsPass(Matrix expected, Matrix predicted, List<double Function(double)> functions, double lr){
    print("Running backprop.");

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
          output.display();
          weights[x].display();
          output = output.dot(weights[x].transpose()!)!;
        }
        dCdY = mseDerivative(preActivated[i]!.performFunction(functions[i]), output);
      }
      print("Hello");
      Matrix dYdZ = preActivated[i]!;
      print("Hello");
      dYdZ = dYdZ.performFunction(functions[i]);
      print("Hello");
      print(preActivated[i]);
      Matrix a=preActivated[i]!;
      print("Hello");
      Matrix dCdW = dYdZ.multiplyByNumber(dCdY)!.multiply(a)!.multiplyByNumber(0.01)!;
      //num sum = result.reduce((value, element) => value + element);
      print("Hello");
      dCdW.display();
    }


    /*double dCdY = 0;

    for(int i = weights.length-1; i > 0; i--){
      Matrix? newExpected = expected;
      Matrix? preActiveCopy = preActivated[preActivated.length-1];

      if(i == weights.length-1){
        //use output layer for dMSE
        dCdY = mseDerivative(predicted, expected);
      }
      else{
        //use expected data backwards to get expected for current layer
        for(int x = i; x > 0; x--){
          newExpected.subtract(biases[biases.length-x]!);
          newExpected.dot(weights[weights.length-x]);
        }

        //use current layer for dMSE
        dCdY = mseDerivative(preActiveCopy!, newExpected);
      }

      //perform the derivative of the current layer's function.
      Function currentFunction = getDerivative(functions[functions.length-i])!;
      Matrix? dYdZ = preActivated[preActivated.length-1]!.performFunction((double x) => currentFunction(x));

      dYdZ.multiply(preActiveCopy!);
      dYdZ.multiply(preActivated[preActivated.length-i]!);
      dYdZ.performFunction((double x) => x*lr);

      weights[weights.length-i].subtract(dYdZ);

      dYdZ.display();
    }*/
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
  print("Forward complete");

  Matrix predicted = new Matrix(row: 1, col: 9);
  predicted.empty();
  predicted.setAt(row: 0, col: 1, value: -1);

  network.backwardsPass(forward!, predicted, functions, 0.01);

  forward = network.forwardPass(input, functions);
  //forward?.display();

}