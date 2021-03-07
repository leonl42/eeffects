import 'relative.dart';
import 'relativePair.dart';

//Subclass of ERelativePair
//_relativeDependent of first ERelative is set to ERelative.widthRelative
//_relativeDependent of second ERelative is set to ERelative.heightRelative
//=>first value is always relative to width and second to height
//=>positional relative
class ERelativePos extends ERelativePair {
  ERelativePos(double firstRelativeValue, double secondRelativeValue)
      : super(ERelative(0, ERelative.widthRelative),
            ERelative(0, ERelative.heightRelative)) {
    firstRelative.relative = firstRelativeValue;
    secondRelative.relative = secondRelativeValue;
  }
}
