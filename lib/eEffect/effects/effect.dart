import 'package:flutter/material.dart';

//Father class for all effects
class EEffect {
  bool _isDrawable;
  bool _updateFromScene;
  String name;
  bool isToggled = false;
  EEffect(this._isDrawable, this._updateFromScene, {this.name = ""});

  void toggle() {
    isToggled = !isToggled;
  }

  bool get updateFromScene => _updateFromScene;
  bool get isDrawable => _isDrawable;

  void update(double deltaTime, Size size) {}

  void draw(Canvas canvas, Size size) {}

  void drawEffect(Canvas canvas, Size size) {}

  void drawLight(Canvas canvas, Size size) {}
}
