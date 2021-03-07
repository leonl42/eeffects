import 'package:flutter/material.dart';
import '../../../eEffect/effects/gradient.dart';
import '../../../eEffect/math/relative.dart';
import '../../../eEffect/math/relativePair.dart';
import '../../../eEffect/math/vector2D.dart';
import 'dart:math';

import '../effect.dart';

class EFire extends EEffect {
  EGradient fireGradient;
  EGradient smokeGradient;
  EGradient lightGradient;

  RadialGradient _radialFireGradient = RadialGradient(colors: []);
  RadialGradient _radialSmokeGradient = RadialGradient(colors: []);
  RadialGradient _radialLightGradient = RadialGradient(colors: []);

  Paint _firePaint = Paint();
  Paint _smokePaint = Paint();
  Paint _lightPaint = Paint();

  List<EParticle> _flameParticleList = [];
  List<EParticle> _smokeParticleList = [];
  //particles that spawn per tick
  int fireParticlesPerTick;
  int smokeParticlesPerTick;
  ERelativePair startPoint;
  EVector2D flameDirection;
  //scatteringAngle = max difference bewtween particleDirection and flameDirection
  ERelative scatteringAngle;
  ERelative startSize;
  ERelative decreaseSize;
  ERelative particleSpeed;
  ERelative glow;
  ERelative lightRadius;
  Rect _gradientRect = Rect.fromPoints(Offset(0, 0), Offset(0, 0));

  EFire(
      this.fireGradient,
      this.smokeGradient,
      this.lightGradient,
      this.fireParticlesPerTick,
      this.smokeParticlesPerTick,
      this.startPoint,
      this.flameDirection,
      this.scatteringAngle,
      this.startSize,
      this.decreaseSize,
      this.glow,
      this.lightRadius,
      this.particleSpeed,
      {String name = ""})
      : super(true, true, name: name) {
    scatteringAngle.relative = scatteringAngle.relative * (pi / 180);
  }

  void _buildGradientRect(Size size) {
    //check what distance particle can travel before disappearing
    //max dist = radius of gradient
    double radius = (startSize.getAbsoluteValue(size) /
            decreaseSize.getAbsoluteValue(size)) *
        particleSpeed.getAbsoluteValue(size);
    _gradientRect = Rect.fromCircle(
        center: startPoint.getAbsolutePair(size).getOffset(), radius: radius);
  }

  void _buildGradients() {
    _radialFireGradient = fireGradient.getRadialGradient();
    _radialSmokeGradient = smokeGradient.getRadialGradient();
    _radialLightGradient = lightGradient.getRadialGradient();
  }

  void _buildPaints(Size size) {
    _firePaint = Paint()
      ..shader = _radialFireGradient.createShader(_gradientRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 13)
      ..blendMode = BlendMode.lighten;
    _smokePaint = Paint()
      ..shader = _radialSmokeGradient.createShader(_gradientRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20)
      ..blendMode = BlendMode.lighten;
    _lightPaint = Paint()
      ..shader = _radialLightGradient.createShader(_gradientRect)
      ..blendMode = BlendMode.multiply;
    if (glow.getAbsoluteValue(size) > 0) {
      _lightPaint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, glow.getAbsoluteValue(size));
    }
  }

  void _spawnFlameParticle(Size size) {
    if (Random().nextInt(2) > 0) {
      scatteringAngle.relative = -scatteringAngle.relative;
    }
    //get startPoint of particle
    ERelativePair particleStartPoint = ERelativePair(
        ERelative(startPoint.getAbsolutePair(size).x, ERelative.absolute),
        ERelative(startPoint.getAbsolutePair(size).y, ERelative.absolute));

    //rotate movement by random angle, where the maximum is scatteringAngle
    EVector2D movement = _getRandomMovementVct(size);
    movement.setLength(particleSpeed.getAbsoluteValue(size));
    _flameParticleList.add(EParticle(particleStartPoint, movement,
        startSize.getAbsoluteValue(size), decreaseSize.getAbsoluteValue(size)));
  }

  void _spawnSmokeParticle(Size size) {
    if (Random().nextInt(2) > 0) {
      scatteringAngle.relative = -scatteringAngle.relative;
    }
    //get startPoint of particle
    ERelativePair particleStartPoint = ERelativePair(
        ERelative(startPoint.getAbsolutePair(size).x, ERelative.absolute),
        ERelative(startPoint.getAbsolutePair(size).y, ERelative.absolute));

    EVector2D movement = _getRandomMovementVct(size);
    movement.setLength(particleSpeed.getAbsoluteValue(size));
    _smokeParticleList.add(EParticle(
        particleStartPoint,
        movement,
        startSize.getAbsoluteValue(size),
        //negative decreaseSize -> particle gets bigger
        -decreaseSize.getAbsoluteValue(size)));
  }

  EVector2D _getRandomMovementVct(Size size) {
    //rotated EVector2D by a random angle, where the maximum is scatteringAngle
    //and the start angle is the one of flameDirection
    return EVector2D(
        (flameDirection.x *
                cos(Random().nextDouble() *
                    scatteringAngle.getAbsoluteValue(size) /
                    2) +
            flameDirection.y *
                sin(Random().nextDouble() *
                    -scatteringAngle.getAbsoluteValue(size) /
                    2)),
        flameDirection.x *
                sin(Random().nextDouble() *
                    scatteringAngle.getAbsoluteValue(size) /
                    2) +
            flameDirection.y *
                cos(Random().nextDouble() *
                    scatteringAngle.getAbsoluteValue(size) /
                    2));
  }

  @override
  void update(double deltaTime, Size size) {
    _buildGradientRect(size);
    _buildGradients();
    _buildPaints(size);
    fireGradient.update(deltaTime);
    smokeGradient.update(deltaTime);
    lightGradient.update(deltaTime);
    for (int i = 0; i < fireParticlesPerTick; i++) {
      _spawnFlameParticle(size);
    }
    for (int i = 0; i < smokeParticlesPerTick; i++) {
      _spawnSmokeParticle(size);
    }
    for (EParticle eParticle in _flameParticleList) {
      eParticle.update(deltaTime, size);
      if (eParticle.radius <= 0) {
        _flameParticleList.remove(eParticle);
      }
    }
    for (EParticle eParticle in _smokeParticleList) {
      eParticle.update(deltaTime, size);
      //determines how big the smoke particle can get
      if (eParticle.radius >= 3 * startSize.getAbsoluteValue(size)) {
        _smokeParticleList.remove(eParticle);
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    drawLight(canvas, size);
    drawEffect(canvas, size);
  }

  void drawEffect(Canvas canvas, Size size) {
    //BlendMode.srcOver so you cant see through the flame

    canvas.saveLayer(null, Paint()..blendMode = BlendMode.srcOver);
    //draw smoke particles
    for (EParticle eParticle in _smokeParticleList) {
      canvas.drawCircle(eParticle.position.getAbsolutePair(size).getOffset(),
          eParticle.radius, _smokePaint);
    }
    canvas.restore();
    canvas.saveLayer(null, Paint()..blendMode = BlendMode.srcOver);
    //draw flame particles
    for (EParticle eParticle in _flameParticleList) {
      canvas.drawCircle(eParticle.position.getAbsolutePair(size).getOffset(),
          eParticle.radius, _firePaint);
    }
    canvas.restore();
  }

  void drawLight(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint()..blendMode = BlendMode.screen);
    for (EParticle eParticle in _flameParticleList) {
      //make new Color list with new alpha values
      List<Color> lightGradientColors = [];
      _radialLightGradient.colors.forEach((color) {
        lightGradientColors.add(Color.fromARGB(
            (color.alpha * (eParticle.radius / eParticle.initRadius))
                .toInt(), //smaller particles produce less light => lower alpha
            color.red,
            color.green,
            color.blue));
      });
      RadialGradient lightGradient =
          RadialGradient(colors: lightGradientColors);

      Offset eParticlePos =
          eParticle.position.getAbsolutePair(size).getOffset();
      double absLightRadius = lightRadius.getAbsoluteValue(size);

      Rect lightGradientRect =
          Rect.fromCircle(center: eParticlePos, radius: absLightRadius);
      _lightPaint.shader = lightGradient.createShader(lightGradientRect);
      canvas.drawCircle(eParticlePos, absLightRadius, _lightPaint);
    }
    canvas.restore();
  }
}

class EParticle {
  ERelativePair position;
  EVector2D movement;
  double radius;
  double initRadius = 0;
  double decreaseRadius;
  EParticle(this.position, this.movement, this.radius, this.decreaseRadius) {
    initRadius = radius;
  }

  void update(double deltaTime, Size size) {
    position.firstRelative.relative += movement.x;
    position.secondRelative.relative += movement.y;

    radius -= decreaseRadius;
  }
}
