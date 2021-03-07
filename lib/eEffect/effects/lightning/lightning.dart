import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../eEffect/effects/colorShift.dart';
import '../../../eEffect/effects/effect.dart';
import '../../../eEffect/math/relative.dart';
import '../../../eEffect/math/relativePair.dart';
import '../../../eEffect/math/relativePos.dart';
import '../../../eEffect/math/vector2D.dart';

class ELightning extends EEffect {
  ERelativePair position;
  ERelativePair _targetPosition = ERelativePos(0, 0);
  double spread;
  ERelative glow;
  ERelative curve;
  int numberOfPoints;
  ERelative width;
  double buildingTimeInTicks;
  EColorShift color;
  List<EVector2D> _pointList = [];
  List<ELightning> _sideLightning = [];
  bool _buildLightningOnNextTick = false;
  bool _fireLightningOnNextTick = false;
  double _ticker = -1;
  double _fireUntilPoint = 0;
  int _fireMultiplier = 1;
  double lightningBlur = 0;
  double _length = 0;
  bool throwsLight = true;
  List<EVector2D> _pathPoint = [];
  List<EVector2D> _first = [];
  List<EVector2D> _last = [];
  int repainter = 1;

  ELightning(
      this.position,
      this.spread,
      this.glow,
      this.width,
      this.curve,
      this.numberOfPoints,
      this.buildingTimeInTicks,
      this.color,
      this.throwsLight,
      this.lightningBlur,
      this.repainter,
      {String name = ""})
      : super(true, true, name: name);
  void buildLightningOnNextTickATTarget(ERelativePair targetPosition) {
    _buildLightningOnNextTick = true;
    _targetPosition = targetPosition;
  }

  void fireLightningIn(double ticks) {
    _ticker = ticks;
  }

  void _buildLightning(Size size) {
    EVector2D absPosition = position.getAbsolutePair(size);
    EVector2D targetPosition = _targetPosition.getAbsolutePair(size);
    _length = (absPosition.getAdd(targetPosition.getMultiply(-1))).getLength();

    _sideLightning.clear();
    _pointList.clear();
    _pointList.add(absPosition);
    _pointList.add(targetPosition);

    double curveSizePerPoint =
        curve.getAbsoluteValue(size) / (numberOfPoints / 2);

    //fill point list till number of points is reached
    //+2 because position and target dont count to numberOfPoints but are in the list
    while (_pointList.length < numberOfPoints + 2) {
      //add a point between 2 existing points and repeat this process until the point limit is reached
      for (int currentIndex = 0;
          currentIndex < _pointList.length - 1;
          currentIndex += 2) {
        if (_pointList.length >= numberOfPoints + 2) {
          break;
        }
        EVector2D vctToNextPointInList = _pointList[currentIndex + 1]
            .getAdd(_pointList[currentIndex].getMultiply(-1));

        //new point is in the middle of the point before it and the point after it
        EVector2D newPoint = _pointList[currentIndex]
            .getAdd(vctToNextPointInList.getMultiply(1 / 2));

        //shift it to the side
        vctToNextPointInList.rotate(90);
        vctToNextPointInList.norm();
        vctToNextPointInList.multiply(curveSizePerPoint);

        //random chance that it will be shifted into the other direction
        if (Random().nextInt(2) > 0) {
          vctToNextPointInList.multiply(-1);
        }
        newPoint.add(vctToNextPointInList);
        _pointList.insert(currentIndex + 1, newPoint);

        //add side lightning
        if (Random().nextDouble() <= spread &&
            _length > 5 &&
            width.getAbsoluteValue(size) > 1) {
          _addSideLightning(size, vctToNextPointInList, newPoint);
        }
      }
    }
    _calcBuildingTimeOfSideLightning(size);
  }

  void _addSideLightning(
      Size size, EVector2D vctToNextPointInList, EVector2D newPoint) {
    vctToNextPointInList.norm();
    vctToNextPointInList.multiply(Random().nextInt(2) > 0
        ? 1 * (Random().nextInt(_length ~/ 2).toDouble() + _length ~/ 8)
        : -1 * (Random().nextInt(_length ~/ 2).toDouble()) + _length ~/ 8);

    EVector2D target = newPoint.getAdd(vctToNextPointInList);
    ERelativePair targetAsRelativePair = ERelativePair(
        ERelative(target.x, ERelative.absolute),
        ERelative(target.y, ERelative.absolute));
    _sideLightning.add(ELightning(
      ERelativePair(ERelative(newPoint.x, ERelative.absolute),
          ERelative(newPoint.y, ERelative.absolute)),
      spread * 2,
      ERelative(glow.getAbsoluteValue(size) * 3 / 4, glow.relativeDependent),
      ERelative(width.getAbsoluteValue(size) / 2, ERelative.absolute),
      ERelative(curve.getAbsoluteValue(size) / 2, ERelative.absolute),
      numberOfPoints ~/ 2,
      buildingTimeInTicks / 2,
      color,
      false,
      lightningBlur,
      repainter,
    )..buildLightningOnNextTickATTarget(targetAsRelativePair));
  }

  //calculate buildingTime of sideLightning by determining how much time is left when the
  //lightning reaches the position of the side lightning
  void _calcBuildingTimeOfSideLightning(Size size) {
    for (ELightning eLightning in _sideLightning) {
      EVector2D eLightningPosition = eLightning.position.getAbsolutePair(size);
      for (int i = 0; i < _pointList.length; i++) {
        if (_pointList[i].x == eLightningPosition.x &&
            _pointList[i].y == eLightningPosition.y) {
          double timeRemaining =
              (buildingTimeInTicks / (_pointList.length - 1)) *
                  (_pointList.length - i + 1);
          eLightning.buildingTimeInTicks = timeRemaining;
          break;
        }
      }
    }
  }

  //calculate when the side lightning should fire by determining when
  //lightning reaches the position of the side lightning
  void _calcFireTimeOfSideLightning(Size size) {
    for (ELightning eLightning in _sideLightning) {
      EVector2D eLightningPosition = eLightning.position.getAbsolutePair(size);
      for (int i = 0; i < _pointList.length; i++) {
        if (_pointList[i].x == eLightningPosition.x &&
            _pointList[i].y == eLightningPosition.y) {
          double timeRemaining =
              (buildingTimeInTicks / (_pointList.length - 1)) * (i + 1);
          eLightning.fireLightningIn(timeRemaining);
          break;
        }
      }
    }
  }

  //build points that are important for the Path()
  //calculate Vector from point to next point
  //rotate it by 90 degrees set its length to width/2 and add it to the point and you got one new Point
  //multiply it by -1, add it to the point and you get the other new point
  //this results in the original point splitting up in 2 new points
  //these 2 new points are used for the path and have a distance of width
  void _buildPathPoints(Size size) {
    _first.clear();
    _last.clear();
    _pathPoint.clear();
    for (int i = 0; i < _fireUntilPoint; i++) {
      if (i == _fireUntilPoint.toInt() - 1) {
        _first.add(_pointList[i]);
      } else {
        EVector2D thisPoint = _pointList[i];
        EVector2D nextPoint = _pointList[i + 1];
        EVector2D thisToNext = nextPoint.getAdd(thisPoint.getMultiply(-1));
        thisToNext.rotate(90);
        thisToNext.setLength(width.getAbsoluteValue(size) / 2);
        _first.add(thisPoint.getAdd(thisToNext));
      }
    }
    for (int i = 0; i < _fireUntilPoint; i++) {
      if (i == _fireUntilPoint.toInt() - 1) {
        _last.insert(0, _pointList[i]);
      } else {
        EVector2D thisPoint = _pointList[i];
        EVector2D nextPoint = _pointList[i + 1];
        EVector2D thisToNext = nextPoint.getAdd(thisPoint.getMultiply(-1));
        thisToNext.rotate(90);
        thisToNext.setLength(-width.getAbsoluteValue(size) / 2);
        _last.insert(0, thisPoint.getAdd(thisToNext));
      }
    }
    _pathPoint = _first + _last;
  }

  void _fire(Size size) {
    _fireUntilPoint = 1;
    _fireMultiplier = 1;
    _calcFireTimeOfSideLightning(size);
  }

  @override
  void update(double deltaTime, Size size) {
    color.update(deltaTime);
    for (ELightning eLightning in _sideLightning) {
      eLightning.update(deltaTime, size);
    }
    _buildPathPoints(size);
    if (_ticker > 0) {
      _ticker -= 1;
      if (_ticker.abs() <= 1) {
        _fireLightningOnNextTick = true;
      }
    }
    if (_buildLightningOnNextTick) {
      _buildLightning(size);
      _buildLightningOnNextTick = false;
    }
    if (_fireLightningOnNextTick) {
      _fire(size);
      _fireLightningOnNextTick = false;
    }
    if (_fireUntilPoint > 0) {
      _fireUntilPoint +=
          ((_pointList.length - 1) / buildingTimeInTicks) * _fireMultiplier;
      if (_fireUntilPoint.isNaN) {
        _fireUntilPoint = 0;
      }
      if (_fireUntilPoint >= _pointList.length - 1) {
        _fireUntilPoint = _pointList.length - 1;
        //reverse the build process
        _fireMultiplier = -_fireMultiplier;
      } else if (_fireUntilPoint <= 0) {
        _fireUntilPoint = 0;
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    drawLight(canvas, size);
    drawEffect(canvas, size);
  }

  void drawEffect(Canvas canvas, Size size) {
    Color currentColor = color.getCurrentColor();

    Path path = Path();
    //move path to position
    path.moveTo(
        position.getAbsolutePair(size).x, position.getAbsolutePair(size).y);

    for (EVector2D pathPoint in _pathPoint) {
      path.lineTo(pathPoint.x, pathPoint.y);
    }

    path.close();
    Paint pathPaint = Paint()..color = currentColor;
    if (lightningBlur > 0) {
      pathPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, lightningBlur);
    }
    pathPaint.blendMode = BlendMode.lighten;

    for (int i = 0; i < repainter; i++) {
      canvas.drawPath(path, pathPaint);
    }

    for (ELightning eLightning in _sideLightning) {
      eLightning.draw(canvas, size);
    }
  }

  void drawLight(Canvas canvas, Size size) {
    Color currentColor = color.getCurrentColor();
    //this does the glowing effect
    RadialGradient rg = RadialGradient(colors: [
      Color.fromARGB(
          10, currentColor.red, currentColor.green, currentColor.blue),
      Color.fromARGB(0, currentColor.red, currentColor.green, currentColor.blue)
    ]);
    for (EVector2D pathPoint in _pathPoint) {
      Rect rect = Rect.fromCircle(
          center: pathPoint.getOffset(),
          radius: glow.getAbsoluteValue(size) * width.getAbsoluteValue(size));
      Paint paint = Paint()
        ..shader = rg.createShader(rect)
        ..blendMode = BlendMode.screen;
      if (glow.getAbsoluteValue(size) > 0) {
        paint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, glow.getAbsoluteValue(size));
      }
      canvas.drawCircle(
          pathPoint.getOffset(), 5 * width.getAbsoluteValue(size), paint);
    }
    if (!throwsLight) {
      return;
    }
    //this does the actual lighting
    for (int i = 1; i < 10; i++) {
      rg = RadialGradient(colors: [
        Color.fromARGB((6 - i / 2).toInt(), currentColor.red,
            currentColor.green, currentColor.blue),
        Color.fromARGB(
            0, currentColor.red, currentColor.green, currentColor.blue)
      ]);
      for (EVector2D pathPoint in _pathPoint) {
        if (Random().nextInt(i + 4) > 0) {
          continue;
        }
        Rect rect = Rect.fromCircle(
            center: pathPoint.getOffset(),
            radius: 10 * i * width.getAbsoluteValue(size));
        Paint paint = Paint()
          ..shader = rg.createShader(rect)
          ..blendMode = BlendMode.screen;
        if (glow.getAbsoluteValue(size) * i > 0) {
          paint.maskFilter = MaskFilter.blur(
              BlurStyle.normal, glow.getAbsoluteValue(size) * i);
        }
        canvas.drawCircle(pathPoint.getOffset(),
            10 * i * width.getAbsoluteValue(size), paint);
      }
    }
  }
}
