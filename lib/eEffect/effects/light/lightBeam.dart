import 'dart:math';

import 'package:flutter/material.dart';
import '../../../eEffect/effects/light/light.dart';
import '../../../eEffect/math/relative.dart';
import '../../../eEffect/math/relativePair.dart';
import '../../../eEffect/math/vector2D.dart';

import '../gradient.dart';

//simple LightBeam
class ELightBeam extends ELight {
  ERelativePair position;
  EVector2D direction;
  ERelative length;
  ERelative angle;
  EGradient gradient;
  ERelative startPositionDist;
  RadialGradient _radialGradient = RadialGradient(colors: []);
  Rect _gradientRect = Rect.fromPoints(Offset(0, 0), Offset(0, 0));
  Paint _paint = Paint();
  int repainter;
  ELightBeam(
      this.position,
      this.direction,
      this.length,
      this.angle,
      //width of the starting end of the light beam
      this.startPositionDist,
      this.gradient,
      double flickerOn,
      double flickerOff,
      ERelative blur,
      ERelative blurPulseRange,
      double blurPulseSpeed,
      this.repainter,
      {String name = ""})
      : super(flickerOn, flickerOff, blur, blurPulseRange, blurPulseSpeed,
            name: name) {
    direction.norm();
    update(1, Size(0, 0));
  }

  void _buildGradient() {
    _radialGradient = gradient.getRadialGradient();
  }

  void _buildRect(Size size) {
    EVector2D absolutePos = position.getAbsolutePair(size);
    double absoluteLength = length.getAbsoluteValue(size);
    _gradientRect = Rect.fromCircle(
        center: absolutePos.getOffset(), radius: absoluteLength);
  }

  void _buildPaint() {
    _paint = Paint()
      ..shader = _radialGradient.createShader(_gradientRect)
      ..blendMode = BlendMode.multiply;
    if (super.currentBlur > 0) {
      _paint.maskFilter = MaskFilter.blur(BlurStyle.normal, super.currentBlur);
    }
  }

  @override
  void update(double deltaTime, Size size) {
    gradient.update(deltaTime);
    _buildGradient();
    _buildRect(size);
    _buildPaint();
    super.update(deltaTime, size);
  }

  void draw(Canvas canvas, Size size) {
    drawLight(canvas, size);
  }

  void drawEffect(Canvas canvas, Size size) {}

  //calculate path for drawing the light
  void drawLight(Canvas canvas, Size size) {
    direction.norm();
    EVector2D absolutePos = position.getAbsolutePair(size);
    double absoluteLength = length.getAbsoluteValue(size);
    double absStartPositionDist = startPositionDist.getAbsoluteValue(size);
    double absAngle = angle.getAbsoluteValue(size);
    EVector2D absPos2 = EVector2D(direction.x, direction.y);
    absPos2.rotate(90);
    absPos2.setLength(absStartPositionDist / 2);

    EVector2D curPos = absPos2.getAdd(absolutePos);
    Path p = Path();
    p.moveTo(curPos.x, curPos.y);

    //rotate direction
    //calculate the length of the rotated "sideline" so that the length of the beam will be absoluteLength
    //add this to curPos and get the pos of the new point
    double lengthOfSideLine = absoluteLength / cos(absAngle * (pi / 180));
    curPos.add((direction.getRotate(absAngle)).getMultiply(lengthOfSideLine));
    p.lineTo(curPos.x, curPos.y);
    //finished one side of the beam

    //do same steps with other side, close the path and get the beam
    absPos2.multiply(-1);
    curPos = absPos2.getAdd(absolutePos);
    curPos.add((direction.getRotate(-absAngle)).getMultiply(lengthOfSideLine));
    p.lineTo(curPos.x, curPos.y);

    curPos = absPos2.getAdd(absolutePos);
    p.lineTo(curPos.x, curPos.y);

    p.close();
    for (int i = 0; i < repainter; i++) {
      canvas.drawPath(p, _paint);
    }
  }
}
