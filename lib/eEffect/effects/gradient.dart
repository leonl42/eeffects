import 'package:flutter/material.dart';
import '../../eEffect/effects/colorShift.dart';

//Custom gradient with ColorShifts instead of colors
//can return a RadialGradient or a LinearGradient
class EGradient {
  List<EColorShift> colorShifts;
  EGradient(this.colorShifts) {
    if (this.colorShifts.isEmpty) {
      this.colorShifts.add(EColorShift([Color.fromARGB(0, 0, 0, 0)], 0));
    }
    if (this.colorShifts.length == 1) {
      this.colorShifts.add(this.colorShifts[0]);
    }
  }

  void update(double deltaTime) {
    for (EColorShift eColorShift in colorShifts) {
      eColorShift.update(deltaTime);
    }
  }

  RadialGradient getRadialGradient() {
    return RadialGradient(
        colors: List.generate(colorShifts.length,
            (index) => colorShifts[index].getCurrentColor()));
  }

  LinearGradient getLinearGradient(Alignment begin, Alignment end) {
    return LinearGradient(
        begin: begin,
        end: end,
        colors: List.generate(colorShifts.length,
            (index) => colorShifts[index].getCurrentColor()));
  }
}
