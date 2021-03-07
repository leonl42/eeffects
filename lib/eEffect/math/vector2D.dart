import 'package:flutter/material.dart';
import 'dart:math' as math;

//class for 2D Vectors

class EVector2D {
  double x = 0;
  double y = 0;

  EVector2D(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void norm() {
    double length = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
    x = x / length;
    y = y / length;
  }

  void add(EVector2D vct) {
    x += vct.x;
    y += vct.y;
  }

  void multiply(double factor) {
    x = x * factor;
    y = y * factor;
  }

  EVector2D getMultiply(double factor) {
    return EVector2D(x * factor, y * factor);
  }

  EVector2D getAdd(EVector2D vct) {
    return EVector2D(x + vct.x, y + vct.y);
  }

  //rotate Vector by multiplying it with the rotation matrix
  void rotate(double alpha) {
    double alphaInRadians = alpha * (math.pi / 180);
    double oldX = x;
    x = x * math.cos(alphaInRadians) + y * math.sin(alphaInRadians);
    y = -oldX * math.sin(alphaInRadians) + y * math.cos(alphaInRadians);
  }

  EVector2D getRotate(double alpha) {
    double alphaInRadians = alpha * (math.pi / 180);
    double newX = x * math.cos(alphaInRadians) + y * math.sin(alphaInRadians);
    double newY = -x * math.sin(alphaInRadians) + y * math.cos(alphaInRadians);
    return EVector2D(newX, newY);
  }

  double getLength() {
    double length = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
    return length.isNaN ? 0 : length;
  }

  double getAngle(EVector2D vct) {
    double xMult = x * vct.x;
    double yMult = y * vct.y;
    double product = xMult + yMult;
    double angle = math.acos(product / (getLength() * vct.getLength()));
    //if vector.length is 0 => handle NaN
    if (angle.isNaN) {
      return 0;
    }
    return angle;
  }

  void setLength(double length) {
    norm();
    multiply(length);
  }

  //provide Offset with values from the vector
  Offset getOffset() {
    double xOffset = x.isNaN ? 0 : x;
    double yOffset = y.isNaN ? 0 : y;

    return Offset(xOffset, yOffset);
  }
}
