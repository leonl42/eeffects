import 'package:flutter/material.dart';
import '../effects/colorShift.dart';
import '../effects/effect.dart';

class EScene extends StatefulWidget {
  Function() _beforeUpdate = () {};
  Function() _afterUpdate = () {};
  double _width = 0;
  double _height = 0;
  EColorShift _darkness = EColorShift([Color.fromARGB(0, 0, 0, 0)], 0);
  List<EEffect> _effects = [];

  double get width => _width;
  double get height => _height;
  set darkness(EColorShift value) {
    _darkness = value;
  }

  EScene({
    required double width,
    required double height,
    EColorShift? darkness,
    List<EEffect>? effects,
    Function()? beforeUpdate,
    Function()? afterUpdate,
  }) {
    _width = width;
    _height = height;
    _darkness = darkness!;
    _effects = effects!;
    _beforeUpdate = beforeUpdate!;
    _afterUpdate = afterUpdate!;
  }

  EEffect? getEffect(String name) {
    return _effects.firstWhere((element) => element.name == name);
  }

  void addEffect(EEffect eEffect) {
    _effects.add(eEffect);
  }

  void addEffects(List<EEffect> eEffects) {
    _effects.addAll(eEffects);
  }

  void removeEffect(String name) {
    _effects.removeWhere((element) => element.name == name);
  }

  void resize(double width, double height) {
    _width = width;
    _height = height;
  }

  ESceneState createState() => ESceneState();
}

class ESceneState extends State<EScene> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  ESceneCanvas eSceneCanvas = ESceneCanvas();

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 16), vsync: this)
          ..addListener(() {
            //make animation controller run infinitely
            if (animationController.value == 1) {
              update(1);
              animationController.reverse();
            } else if (animationController.value == 0) {
              update(1);
              animationController.forward();
            }
          });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void update(double deltaTime) {
    widget._beforeUpdate();

    setState(() {
      //update all effects and provide canvas with updated variables
      for (EEffect eEffect in widget._effects) {
        if (eEffect.updateFromScene) {
          eEffect.update(deltaTime, Size(widget._width, widget._height));
        }
      }
      eSceneCanvas.updateCanvasValues(widget._darkness, widget._effects);
    });

    widget._afterUpdate();
  }

  Widget build(BuildContext context) {
    return Container(
      width: widget._width,
      height: widget._height,
      child: Stack(
        children: [
          Container(
            width: widget._width,
            height: widget._height,
            child: CustomPaint(
              painter: eSceneCanvas,
            ),
          ),
          Container(
            width: 0,
            height: animationController.value,
          )
        ],
      ),
    );
  }
}

class ESceneCanvas extends CustomPainter {
  EColorShift _darkness = EColorShift([Color.fromARGB(0, 0, 0, 0)], 0);
  List<EEffect> _effects = [];

  void updateCanvasValues(EColorShift darkness, List<EEffect> effects) {
    _darkness = darkness;
    _effects = effects;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)));
    //save current Layer of canvas
    //set BlendMode to multiply to multiply everything that is on the screen with what will be drawn when canvas.restore() is called
    canvas.saveLayer(null, Paint()..blendMode = BlendMode.multiply);

    //draw shadow
    canvas.drawRect(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
        Paint()..color = _darkness.getCurrentColor());

    canvas.saveLayer(null, Paint()..blendMode = BlendMode.screen);

    //call drawLight on all effects
    for (EEffect eEffect in _effects) {
      if (!eEffect.isToggled && eEffect.isDrawable) {
        eEffect.drawLight(canvas, size);
      }
    }
    canvas.restore();
    canvas.restore();

    //call drawEffect on all effects
    for (EEffect eEffect in _effects) {
      if (!eEffect.isToggled && eEffect.isDrawable) {
        eEffect.drawEffect(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
