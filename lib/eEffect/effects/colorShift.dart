import 'package:flutter/material.dart';

//List of colors where the current color changes
//current color moves linear from one color to the one that follows in the list
//if last color is reached next color is the one in the beginning
//with a shiftSpeed of 1 the current Color jumps in 1 tick from one color to another

class EColorShift {
  List<Color> _colors;
  double _shiftSpeed;
  double _currentShift = 0;
  Color _currentColor = Color.fromARGB(0, 0, 0, 0);
  EColorShift(this._colors, this._shiftSpeed) {
    //assign currentColor
    if (_colors.isNotEmpty) {
      _currentColor = this._colors[0];
    }

    //check if shift speed is in bounds 0 and 1
    if (_shiftSpeed < 0 || _shiftSpeed > 1) {
      throw ("_shiftSpeed has a value of $_shiftSpeed, while a value within 0 and 1 was expected. Class: EColorShift");
    }
  }

  void update(double deltaTime) {
    _currentShift += _shiftSpeed * deltaTime;
    if (_currentShift >= _colors.length) {
      _currentShift -= _colors.length;
    }
  }

  void buildColor() {
    int indexColorFromShift = _currentShift.toInt();
    int indexColorToShift = indexColorFromShift + 1;
    if (indexColorToShift == _colors.length) {
      indexColorToShift = 0;
    }
    Color colorFromShift = _colors[indexColorFromShift];
    Color colorToShift = _colors[indexColorToShift];
    double relativeCurrentShift = _currentShift - indexColorFromShift;
    int a = (colorFromShift.alpha +
            (colorToShift.alpha - colorFromShift.alpha) * relativeCurrentShift)
        .toInt();
    int r = (colorFromShift.red +
            (colorToShift.red - colorFromShift.red) * relativeCurrentShift)
        .toInt();
    int g = (colorFromShift.green +
            (colorToShift.green - colorFromShift.green) * relativeCurrentShift)
        .toInt();
    int b = (colorFromShift.blue +
            (colorToShift.blue - colorFromShift.blue) * relativeCurrentShift)
        .toInt();
    _currentColor = Color.fromARGB(a, r, g, b);
  }

  Color getCurrentColor() {
    buildColor();
    return _currentColor;
  }
}
