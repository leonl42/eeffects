import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'vector2D.dart';

//value that is relative to the length of an EVector2D represented by an angle: _relativeDependent
//length of this EVector2D is the maximum length that this Vector can have while still beeing within the scene
//an angle of 0 is represented as EVector2D(1,0) => relative to width
class ERelative {
  static double widthRelative = 0;
  static double heightRelative = 90;
  static double widthAndHeightRelative = 45;
  static double absolute = -1;
  double relativeDependent;
  double relative;

  ERelative(this.relative, this.relativeDependent) {
    //check if all values are within bounds or else throw error
    //relative of 180 is queal to relative of 0 => only angles from 0 to 179 needed
    if (this.relativeDependent < -1 || this.relativeDependent > 179) {
      throw ("relativeDependent has a value of $relativeDependent ,while a value within -2 and 179 was expected. Class: ERelative");
    }
  }

  double getAbsoluteValue(Size size) {
    double relativeAngle = relativeDependent;
    //if ERelative is absolute return the value
    if (relativeAngle == -1) {
      return relative;
    }
    //get Vector that goes from on corner of the scene to the corner at the other end (diagonally)
    EVector2D sizeVct = EVector2D(size.width, size.height);
    double firstAngle = sizeVct.getAngle(EVector2D(1, 0)) * (180 / pi);
    double thirdAngle = 90 + firstAngle;

    //subdivide the rect into 4 rectangles
    //First is fom Vector(1,0) to top right corner
    //Second is from top right corner to Vector(0,1)
    //Third is from top Vector(0,1) to top left corner
    //Fourth is from top left corner to Vector(-1,0)
    //calculate maximum of length of Vector provided by relativeAngle => the angle that the value is relative to,
    //by checking in which rectangle it is and using math.cos()
    //convert degrees to radians by multiplying it with (pi / 180)
    if (relativeAngle <= firstAngle) {
      return relative * size.width / (cos(relativeAngle * (pi / 180)));
    } else if (relativeAngle <= 90) {
      return relative * size.height / (cos((90 - relativeAngle) * (pi / 180)));
    } else if (relativeAngle <= thirdAngle) {
      return relative *
          size.height /
          (cos((thirdAngle - relativeAngle) * (pi / 180)));
    } else if (relativeAngle <= 180) {
      return relative * size.width / (cos((180 - relativeAngle) * (pi / 180)));
    }
    return 0;
  }
}
