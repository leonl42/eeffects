import 'package:flutter/material.dart';
import '../../../eEffect/effects/gradient.dart';
import '../../../eEffect/math/relative.dart';
import '../../../eEffect/math/relativePair.dart';
import '../../../eEffect/math/vector2D.dart';

import 'light.dart';

//simple pointLight
class ERadialLight extends ELight {
  ERelativePair position;
  ERelative radius;
  EGradient gradient;
  RadialGradient radialGradient = RadialGradient(colors: []);
  Rect _gradientRect = Rect.fromPoints(Offset(0, 0), Offset(0, 0));
  Paint _paint = Paint();
  int repainter;

  ERadialLight(
      this.position,
      this.radius,
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
    update(1, Size(0, 0));
  }

  void _buildGradient() {
    radialGradient = gradient.getRadialGradient();
  }

  void _buildRect(Size size) {
    double absRadius = radius.getAbsoluteValue(size);
    EVector2D absPos = position.getAbsolutePair(size);

    _gradientRect = Rect.fromPoints(
        Offset(absPos.x - absRadius, absPos.y - absRadius),
        Offset(absPos.x + absRadius, absPos.y + absRadius));
  }

  void _buildPaint() {
    _paint = Paint()
      ..shader = radialGradient.createShader(_gradientRect)
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
  @override
  void drawLight(Canvas canvas, Size size) {
    for (int i = 0; i < repainter; i++) {
      canvas.drawCircle(position.getAbsolutePair(size).getOffset(),
          radius.getAbsoluteValue(size), _paint);
    }
  }
}
