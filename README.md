# EEffects

Flutter package providing a variety of effects:

- Point Lights
- Light Beams
- Fire
- Lightning bolts

Documentation is below Examples

# Examples

Make a Light Beam that follows your mouse and changes colors <br/>
Note that this will actually light up the website if you<br/>
put this effect on top of an actual website

![](https://media.giphy.com/media/4DOmuMuTcDXTQ60EXX/giphy.gif)

```
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  EScene? scene;

  MyApp() {
    scene = EScene(
      width: 0,
      height: 0,
      effects: [
        ELightBeam(
            ERelativePos(0.5, 0.5),
            EVector2D(1, 0),
            ERelative(0.5, ERelative.widthAndHeightRelative),
            ERelative(10, ERelative.absolute),
            ERelative(0, ERelative.absolute),
            EGradient([
              EColorShift([Colors.red, Colors.blue], 0.01),
              EColorShift([Colors.blue, Colors.red], 0.01)
            ]),
            1,
            0,
            ERelative(100, ERelative.absolute),
            ERelative(2, ERelative.absolute),
            0.1,
            1,
            name: "Example Beam")
      ],
      darkness: EColorShift([Color.fromARGB(255, 0, 0, 0)], 0),
      afterUpdate: () {
        EEffect effect = scene!.getEffect("Example Beam")!;
        if (effect is ELightBeam) {
          ELightBeam ourLightBeam = effect;
          //equivalent to mousePos - ourLightBeam.direction
          EVector2D newDirection = mousePos.getAdd(ourLightBeam.position
              .getAbsolutePair(Size(scene!.width, scene!.height))
              .getMultiply(-1));
          ourLightBeam.direction = newDirection;
        }
      },
      beforeUpdate: () {},
    );
  }

  EVector2D mousePos = EVector2D(0, 0);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: LayoutBuilder(builder: (context, size) {
      scene!.resize(size.biggest.width, size.biggest.height);
      return MouseRegion(
        child: scene,
        onHover: (PointerHoverEvent pointerHoverEvent) {
          mousePos = EVector2D(
              pointerHoverEvent.position.dx, pointerHoverEvent.position.dy);
        },
      );
    })));
  }
}
```

A Flame

![](https://media.giphy.com/media/cKvl5S5TLeXTrn46Dp/giphy.gif)

```
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  EScene? scene;

  MyApp() {
    scene = EScene(
      width: 0,
      height: 0,
      effects: [
        EFire(
            EGradient([
              EColorShift([Colors.red], 0),
              EColorShift([Colors.orange.shade800], 0),
              EColorShift([Colors.orange.shade600], 0)
            ]),
            EGradient([
              EColorShift([Color.fromARGB(10, 100, 100, 100)], 0)
            ]),
            EGradient([
              EColorShift([Color.fromARGB(20, 140, 100, 60)], 0),
              EColorShift([Color.fromARGB(10, 140, 100, 60)], 0)
            ]),
            1,
            0,
            ERelativePos(0.5, 0.5),
            EVector2D(0, -1),
            ERelative(30, ERelative.absolute),
            ERelative(40, ERelative.absolute),
            ERelative(2, ERelative.absolute),
            ERelative(40, ERelative.absolute),
            ERelative(150, ERelative.absolute),
            ERelative(8, ERelative.absolute)),
      ],
      darkness: EColorShift([Color.fromARGB(255, 0, 0, 0)], 0),
      afterUpdate: () {},
      beforeUpdate: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: LayoutBuilder(builder: (context, size) {
      scene!.resize(size.biggest.width, size.biggest.height);
      return Container(
        child: scene,
      );
    })));
  }
}
```

Or make a lightning that strikes where you click <br/>
note that the number of points is very high <br/>
you might experience lag on a slow device <br/>
just turn that number a little bit down and you should be fine

![](https://media.giphy.com/media/PcnlCqYdpWyqiEMRTc/giphy.gif)

```
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  EScene? scene;

  MyApp() {
    scene = EScene(
      width: 0,
      height: 0,
      effects: [
        ELightning(
            ERelativePos(0.5, 0),
            0.02,
            ERelative(1, ERelative.absolute),
            ERelative(20, ERelative.absolute),
            ERelative(600, ERelative.absolute),
            50,
            5,
            EColorShift([Color.fromARGB(255, 80, 0, 255)], 0),
            true,
            8,
            1,
            name: "Example Lightning"),
      ],
      darkness: EColorShift([Color.fromARGB(255, 0, 0, 0)], 0),
      afterUpdate: () {},
      beforeUpdate: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: LayoutBuilder(builder: (context, size) {
      scene!.resize(size.biggest.width, size.biggest.height);
      return GestureDetector(
        child: scene,
        onTapDown: (TapDownDetails tapDownDetails) {
          EEffect effect = scene!.getEffect("Example Lightning")!;
          if (effect is ELightning) {
            ELightning ourLightning = effect;
            ourLightning.buildLightningOnNextTickATTarget(ERelativePair(
                ERelative(tapDownDetails.globalPosition.dx, ERelative.absolute),
                ERelative(
                    tapDownDetails.globalPosition.dy, ERelative.absolute)));

            ourLightning.fireLightningIn(1);
          }
        },
      );
    })));
  }
}
```

# Documentation

## EVector2D

Implementation of simple 2D vectors.

#### Constructors:

- **EVector2D(double x, double y)**

#### Variables:

- **x**
- **y**

#### Methods:

- **norm() -> void** <br/> sets the length of the vector to 1
- **add(EVector2D vct) -> void** <br/> adds another vector to this one by adding their values
- **getAdd(EVector2D vct) -> EVector2D** <br/> returns an `EVector2D` containing the values of this vector after adding vct
- **multiply(double value) -> void** <br/> multiplies this vector by multiplying `x` and `y` with value
- **getMultiply(double value) -> EVector2D** <br/> returns an `EVector2D` containing the values of this vector multiplied with value
- **rotate(double angle) -> void** <br/> rotates the vector by the given angle in degrees
- **getRotate(double angle) -> EVector2D** <br/> returns an `EVector2D` that is equivalent to this one but rotated by the given angle in degrees
- **getLength() -> double** <br/> returns the length of this vector
- **getAngle(EVector2D vct) -> double** <br/> returns the angle between this vector and vct in radians
- **setLength(double value) -> void** <br/> set the length of this vector to value
- **getOffset() -> Offset** <br/> returns the offset containing the values of the vector

## ERelative

holds a value that is relative to the length of an `EVector2D` represented by an angle: `relativeDependent`
length of this `EVector2D` is the maximum length that this vector can have while still being within the scene
an angle of 0 is represented as `EVector2D(1,0)` => relative to width

#### Constructors:

- **ERelative(double relative, double relativeDependent)** <br/> `relativeDependent` can be any value bigger than 0 and smaller than 179 or -1<br/>
  if `relativeDependent` is bigger than 0 and smaller than 179, `relative` is relative to the `EVector2D` represented by this angle<br/>
  an angle of 90 represents the `EVector2D(0,1)` and the value is relative to the height<br/>
  if `relativeDependent` is -1, `relative` is absolute and `getAbsoluteValue` will just return `relative`<br/>
  so if `relativeDependent` is 90 and `relative` is 0.5, the absolute value will be half the height

#### Variables:

- **relative**
- **relativeDependent**

#### Pre-defined Values:

- **ERelative.widthRelative = 0**
- **ERelative.heightRelative = 90**
- **ERelative.widthAndHeightRelative = 45**
- **ERelative.absolute = -1**

#### Methods:

- **getAbsoluteValue(Size size, EVector2D direction) -> double** <br/> returns the absolute value

## ERelativePair

Contains 2 `ERelative`

#### Constructors:

- **ERelativePair(ERelative firstRelative, ERelative secondRelative)**

#### Variables:

- **ERelative firstRelative**
- **ERelative secondRelative**

#### Methods:

- **set setFirstRelativeValue(double value)** <br/> sets the `relative` of `firstRelative`
- **get getFirstRelativeValue -> double** <br/> returns the `relative` of `firstRelative`
- **set setSecondRelativeValue(double value)** <br/> sets the `relative` of `secondRelative`
- **get getSecondRelativeValue -> double** <br/> returns the `relative` of `secondRelative`
- **getAbsolutePair(Size size, EVector2D direction) -> EVector2D** <br/> returns the absolutes of the two `ERelatives` stored in an `EVector2D`

## ERelativePos

Subclass of ERelativePair<br/>
`relativeDependent` of first `ERelative` is set to `ERelative.widthRelative`<br/>
`relativeDependent` of second `ERelative` is set to `ERelative.heightRelative`<br/>
=>first value is always relative to width and second to height<br/>
=>positional relative

#### Constructors:

- ERelativePos(double firstRelativeValue, double secondRelativeValue)

## EColorShift

List of colors where the current color changes<br/>
current color moves linear from one color to the one that follows in the list<br/>
if last color is reached next color is the one in the beginning<br/>
with a shiftSpeed of 1, the current Color jumps in 1 tick from one color to the next one

#### Constructors:

- **EColorShift(List<Color> colors, double shiftSpeed)**

#### Variables:

- **List<Color> colors**
- **double shiftSpeed**
- **double currentShift**
- **Color currentColor**

#### Methods:

- **update(double deltaTime) -> void** <br/> updates all values
- **buildColor() -> void** <br/> assigns the current Color to `currentColor`
- **getCurrentColor -> Color** <br/> returns `currentColor`

## EGradient

Custom gradient with `ColorShifts` instead of colors<br/>
can return a `RadialGradient` or a `LinearGradient`

#### Constructors:

- **EGradient(List<EColorShift> colorShifts)**

#### Variables:

- **List<EColorShift> colorShifts**

#### Methods:

- **update(double deltaTime) -> void** <br/> updates the `EGradient`
- **getRadialGradient() -> RadialGradient** <br/> returns a `RadialGradient`
- **getLinearGradient(Alignment begin, Alignment end)** -> LinearGradient <br/> returns a `LinearGradient`

## EEffect

#### Constructors:

- **EEffect(double isDrawable, double updateFromScene, {String name = ""})**

#### Variables:

- **String name**<br/> name of the `EEffect`
- **bool isToggled = false** <br/>if `Effect` is toggled it won't be drawn

#### Methods:

- **update(double deltaTime, Size size) -> void** <br/>
- **draw(Canvas canvas, Size size) -> void** <br/>
- **drawEffect(Canvas canvas, Size size) -> void** <br/>
- **drawLight(Canvas canvas, Size size) -> void** <br/>
- **toggle() -> void** <br/> changes isToggled

## ELight

Subclass of `EEffect`

#### Constructors:

- **ELight (double flickerOn, double flickerOff, ERelative blur, <br/> ERelative blurPulseRange,double blurPulseSpeed,{String name = ""})**

#### Variables:

- **ERelative blur** <br/> blur value
- **double \_currentBlur = 0**<br/>
- **double \_newBlur = 0**<br/> new blur value that currentBlur will change to
- **ERelative blurPulseRange**<br/> currentBlur will change linear to random values <br/> within [blur-blurPulseRange,blur+blurPulseRange]
- **double blurPulseSpeed**<br/> value between 0 and 1. If blurPulseSpeed is one, currentBlur <br/> will change in one tick to newBlur
- **double flickerOn**<br/>chance that light will turn on when off
- **double flickerOff**<br/>chance that light will turn off when on

#### Methods:

- **get currentBlur() -> double** <br/> returns the current blur
- **update(double deltaTime, Size size) -> void** <br/>

## ERadialLight

Simple point light. Subclass of `ELight`

#### Constructors:

- **ERadialLight(ERelativePair position, ERelative radius, EGradient gradient, <br/>double flickerOn,
  double flickerOff, ERelative blur,<br/>ERelative blurPulseRange, double blurPulseSpeed, int repainter,<br/>{String name = ""})**

#### Variables:

- **ERelativePair position**
- **ERelative radius**
- **EGradient gradient**
- **int repainter** <br/> how often the light will be painted

### ELightBeam

#### Constructors:

- **ELightBeam(ERelativePair position, EVector2D direction, ERelative length,<br/>ERelative angle, ERelative startPositionDist, EGradient gradient,<br/>double flickerOn, double flickerOff, ERelative blur,<br/>ERelative blurPulseRange, double blurPulseSpeed, int repainter,<br/>{String name = ""})**

#### Variables:

- **ERelativePair position**
- **EVector2D direction**
- **ERelative length**
- **ERelative angle**
- **EGradient gradient**
- **ERelative startPositionDist** <br/> how wide the light beam is at the start position `position`
- **int repainter** <br/> how often the light will be painted

## EFire

Subclass of `EEffect`

#### Constructors:

- **EFire(
  EGradient fireGradient,
  EGradient smokeGradient,
  EGradient lightGradient,<br/>
  int fireParticlesPerTick,
  int smokeParticlesPerTick,
  ERelativePair startPoint,<br/>
  EVector2D flameDirection,
  ERelative scatteringAngle,
  ERelative startSize,<br/>
  ERelative decreaseSize,
  ERelative glow,
  ERelative lightRadius,<br/>
  ERelative particleSpeed,
  {String name = ""})**

#### Variables:

- **EGradient fireGradient**
- **EGradient smokeGradient**
- **EGradient lightGradient**
- **int fireParticlesPerTick** <br/> fire particles that spawn per tick
- **int smokeParticlesPerTick** <br/> smoke particles that spawn per tick
- **ERelativePair startPoint**
- **EVector2D flameDirection**
- **ERelative scatteringAngle** <br/> max difference bewtween particleDirection and `flameDirection`
- **ERelative startSize** <br/> start size of particles
- **ERelative decreaseSize** <br/> value that particles shrink per tick
- **ERelative particleSpeed**
- **ERelative glow**
- **ERelative lightRadius**

## ELightning

Subclass of `EEffect`

#### Constructors:

- **ELightning(
  ERelativePair position,
  double spread,
  ERelative glow,<br/>
  ERelative width,
  ERelative curve,
  int numberOfPoints,<br/>
  double buildingTimeInTicks,
  EColorShift color,
  bool throwsLight,<br/>
  double lightningBlur,
  int repainter,
  {String name = ""})**

#### Variables:

- **ERelativePair position**
- **double spread** <br/> value between 0 and 1. Chance that a sub lightning will appear on a point<br/>values below 0.08 are recommended
- **ERelative glow**
- **ERelative width** <br/> width of the lightning
- **ERelative curve** <br/> curve value of the lightning<br/> this is the max width that the whole lightning can have<br/> for a lot of points absolute values above 400 are recommended
- **int numberOfPoints** <br/> number of points the lightning will have <br/> more points results in a better look but also in less fps
- **double buildingTimeInTicks**<br/> time that the lightning will take to build itself from position to its destination<br/>it will take the same time to erase itself
- **EColorShift color**
- **bool throwsLight**
- **double lightningBlur**
- **int repainter**<br/> how often the lightning should be painted

#### Methods:

- **buildLightningOnNextTickATTarget(ERelativePair targetPosition) -> void** <br/> will build the lightning bold and make all the preparation for drawing it
- **fireLightningIn(double ticks) -> void**<br/> will actually make the lightning appear in `ticks` ticks<br/> if you call `fireLightningIn(1)` the lightning will appear on the next tick <br/> if you call `fireLightningIn(0)` nothing will happen

## EScene

#### Constructors:

- **EScene({
  required double width,
  required double height,
  EColorShift? \_darkness,<br/>
  List<EEffect>? effects,
  Function()? beforeUpdate,
  Function()? afterUpdate
  })**

#### Variables:

- **double \_width = 0**
- **double \_height = 0**
- **EColorShift \_darkness = EColorShift([Color.fromARGB(0, 0, 0, 0)], 0)** <br/>
  color that the are with no light will have

#### Methods:

- **get width -> double** <br/>returns width
- **get height > double** <br/>returns height
- \*\*set darkness(EColorShift value) <br/> sets darkness
- **getEffect(String name) -> EEffect?** <br/> returns Effect with the name `name`
- **addEffect(EEffect eEffect) -> void**
- **addEffects(List<EEffect> eEffects) -> void**
- **removeEffect(String name) -> void**
- **resize(double width, double height) -> void** <br/> resizes the scene
