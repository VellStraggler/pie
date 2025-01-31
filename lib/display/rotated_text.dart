import 'dart:math';
import 'dart:ui';

import 'package:pie_agenda/pie/diameter.dart';
import 'package:pie_agenda/pie/slice.dart';

const double textOffsetMult = 0.6;

class RotatedText {
  Slice slice;
  double textAngle;
  double textX;
  double textY;

  RotatedText(this.slice, Offset centerOffset)
      : textAngle = 0,
        textX = 0,
        textY = 0 {
    double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
    if (start < 0) {
      start += (2 * pi);
    }
    textAngle = start + slice.getDurationToRadians() / 2;
    textX = centerOffset.dx +
        Diameter.instance.pieDiameter / 2 * textOffsetMult * cos(textAngle);
    textY = centerOffset.dy +
        Diameter.instance.pieDiameter / 2 * textOffsetMult * sin(textAngle);
  }
}
