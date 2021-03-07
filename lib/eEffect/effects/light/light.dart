import 'package:flutter/material.dart';
import '../../../eEffect/math/relative.dart';
import 'dart:math';

import '../effect.dart';

class ELight extends EEffect {
  ERelative blur;
  double _currentBlur = 0;
  double _newBlur = 0;
  ERelative blurPulseRange;
  //value that gets added to _currentBlur
  double blurPulseSpeed;
  //chance that light will turn on when off
  double flickerOn;
  //chance that light will turn off when on
  double flickerOff;

  ELight(this.flickerOn, this.flickerOff, this.blur, this.blurPulseRange,
      this.blurPulseSpeed,
      {String name = ""})
      : super(true, true, name: name) {
    this._currentBlur = blur.getAbsoluteValue(Size(0, 0));
    if (blurPulseSpeed < 0 || blurPulseSpeed > 1) {
      throw ("blurPulseSpeed has a value of $blurPulseSpeed, while a value within 0 and 1 was expected. Class: ELight");
    }
  }

  double get currentBlur => _currentBlur;

  @override
  void update(double deltaTime, Size size) {
    //will change currentBlur linear to random values within [blur-blurPulseRange,blur+blurPulseRange]
    double absBlurPulseRange = blurPulseRange.getAbsoluteValue(size);
    double absBlur = blur.getAbsoluteValue(size);

    //if newBlur is reached set a new "targetBlur"
    if ((_currentBlur - _newBlur).abs() <=
            (absBlurPulseRange * blurPulseSpeed).abs() ||
        _newBlur == 0) {
      //blur goes up
      if (_currentBlur <= absBlur) {
        _newBlur = absBlur + absBlurPulseRange * Random().nextDouble();
        blurPulseSpeed = blurPulseSpeed.abs();
        //blur goes down
      } else if (_currentBlur > absBlur) {
        _newBlur = absBlur - absBlurPulseRange * Random().nextDouble();
        blurPulseSpeed = -blurPulseSpeed.abs();
      }
    }
    _currentBlur += absBlurPulseRange * blurPulseSpeed;

    if (super.isToggled) {
      if (Random().nextDouble() <= flickerOn) {
        super.toggle();
      }
    } else {
      if (Random().nextDouble() <= flickerOff) {
        super.toggle();
      }
    }

    //safety if currentBlur gets out of range to prevent error thrown
    if (_currentBlur <= 0) {
      _currentBlur = 1;
    } else if (_currentBlur > (absBlurPulseRange + absBlur)) {
      _currentBlur = (absBlurPulseRange + absBlur);
    }
  }
}
