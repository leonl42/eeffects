import 'package:flutter/material.dart';
import 'relative.dart';
import 'vector2D.dart';

//Contains two ERelative

class ERelativePair {
  ERelative firstRelative;
  ERelative secondRelative;

  ERelativePair(this.firstRelative, this.secondRelative);

  //return EVector2D containing the values of the two ERelative
  EVector2D getAbsolutePair(Size size) {
    return EVector2D(firstRelative.getAbsoluteValue(size),
        secondRelative.getAbsoluteValue(size));
  }

  set setFirstRelativeValue(double val) {
    firstRelative.relative = val;
  }

  get getFirstRelativeValue => firstRelative.relative;

  set setSecondRelativeValue(double val) {
    secondRelative.relative = val;
  }

  get getSecondRelativeValue => secondRelative.relative;
}
