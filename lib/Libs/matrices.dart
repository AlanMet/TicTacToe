import 'dart:math';

class Matrix {
  late List<List> _matrix;

  int _row = 0;
  int _col = 0;

  get matrix => _matrix;
  get row => _row;
  get col => _col;

  Matrix({required int row, required int col}) {
    _row = row;
    _col = col;
  }

  void generate(double min, double max) {
    Random rand = Random();
    _matrix = List<List>.generate(
        _row,
        (i) => List<dynamic>.generate(
            _col, (index) => (rand.nextDouble() * (max - min) + min),
            growable: false),
        growable: false);
  }

  void empty() {
    _matrix = List<List>.generate(_row,
        (i) => List<dynamic>.generate(_col, (index) => 0.0, growable: false),
        growable: false);
  }

  void fromList(List<List> matrix) {
    _matrix = matrix;
  }

  double getAt({required int row, required int col}) {
    return _matrix[row][col];
  }

  void setAt({required int row, required int col, required double value}) {
    _matrix[row][col] = value;
  }

  Matrix? dot(Matrix matrixB) {
    if (_col == matrixB.row) {
      Matrix newMatrix = Matrix(row: _row, col: matrixB.col);
      newMatrix.empty();

      for (int i = 0; i < _row; i++) {
        for (int j = 0; j < matrixB.col; j++) {
          double sum = 0;
          for (int k = 0; k < _col; k++) {
            sum += getAt(row: i, col: k) * matrixB.getAt(row: k, col: j);
          }
          newMatrix.setAt(row: i, col: j, value: sum);
        }
      }
      print("Matrix operation performed.");
      print("${_row}x${_col} ⋅ ${matrixB.row}x${matrixB.col} = ${newMatrix.row}x${newMatrix.col}\n");
      return newMatrix;
    }
    print("Cannot perform matrix operation");
    print("${_row}x${_col} ⋅ ${matrixB.row}x${matrixB.col}\n");
    return null;
  }

  Matrix? flipMatrix(Matrix matrixB) {
    return matrixB.performFunction((double num) => num * -1);
  }

  Matrix? add(Matrix matrixB) {
    if (_col == matrixB.col && _row == matrixB.row) {
      Matrix newMatrix = Matrix(row: _row, col: matrixB.col);
      newMatrix.empty();
      for (int i = 0; i < _row; i++) {
        for (int j = 0; j < matrixB.col; j++) {
          newMatrix.setAt(
              row: i,
              col: j,
              value: getAt(row: i, col: j) + matrixB.getAt(row: i, col: j));
        }
      }
      //print("Addition performed successfully.\n");
      return newMatrix;
    }
    //print("Cannot perform matrix operation");
    //print("${_row}x$_col ⋅ ${matrixB.row}x${matrixB.col}\n");
    return null;
  }

  Matrix? multiply(Matrix matrixB) {
    if (_col == matrixB.col && _row == matrixB.row) {
      Matrix newMatrix = Matrix(row: _row, col: matrixB.col);
      newMatrix.empty();
      for (int i = 0; i < _row; i++) {
        for (int j = 0; j < matrixB.col; j++) {
          newMatrix.setAt(
              row: i,
              col: j,
              value: getAt(row: i, col: j) * matrixB.getAt(row: i, col: j));
        }
      }
      //print("Addition performed successfully.\n");
      return newMatrix;
    }
    //print("Cannot perform matrix operation");
    //print("${_row}x$_col ⋅ ${matrixB.row}x${matrixB.col}\n");
    return null;
  }

  Matrix? multiplyByNumber(double x) {
      Matrix newMatrix = Matrix(row: _row, col: _col);
      newMatrix.empty();
      for (int i = 0; i < _row; i++) {
        for (int j = 0; j < _col; j++) {
          newMatrix.setAt(
              row: i,
              col: j,
              value: getAt(row: i, col: j) * x);
        }
      }
      //print("Addition performed successfully.\n");
      return newMatrix;
    //print("Cannot perform matrix operation");
    //print("${_row}x$_col ⋅ ${matrixB.row}x${matrixB.col}\n");
    return null;
  }

  Matrix? transpose(){
    Matrix newMatrix = Matrix(row: _col, col: _row);
    newMatrix.empty();
    for (int i = 0; i < _row; i++) {
      for (int j = 0; j < getRow(i)!.length; j++) {
        newMatrix.setAt(row: j, col: i, value: getRow(i)![j]);
      }
    }
    return newMatrix;
  }

  List? getRow(int row) {
    return _matrix[row];
  }

  Matrix? subtract(Matrix matrixB) {
    return add(flipMatrix(matrixB)!);
  }

  Matrix performFunction(Function(double) function) {
    Matrix newMatrix = Matrix(row: _row, col: _col);
    newMatrix.empty();
    for (int i = 0; i < _row; i++) {
      for (int j = 0; j < _col; j++) {
        double result = function(getAt(row: i, col: j));
        newMatrix.setAt(row: i, col: j, value: result);
      }
    }
    return newMatrix;
  }

  void display() {
    for (var i = 0; i < _row; i++) {
      print(_matrix[i]);
    }
    print("Done. \n");
  }

  void getSize() {
    print("${_row}x${_col}");
  }
}

void main() {
  Matrix matrix = new Matrix(row: 3, col: 3);
  matrix.generate(-1, 1);
  matrix.display();
  print(matrix.getAt(row: 0, col: 1));
  matrix = matrix.transpose()!;
  matrix.display();
  //print("");
}
