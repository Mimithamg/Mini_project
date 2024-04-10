import 'package:flutter/material.dart';
import 'package:parking_app/lib/utils/app_export.dart';

class AppDecoration {
  // Light decorations
  static BoxDecoration get light => BoxDecoration(
        color: appTheme.gray50,
      );

  //Comment/Uncomment the below code based on your Flutter SDK version.

  // For Flutter SDK Version 3.7.2 or greater.
  static double get strokeAlignInside => BorderSide.strokeAlignInside;
  static double get strokeAlignCenter => BorderSide.strokeAlignCenter;
  static double get strokeAlignOutside => BorderSide.strokeAlignOutside;

  // For Flutter SDK Version 3.7.1 or less.
  // static StrokeAlign get strokeAlignInside => StrokeAlign.inside;
  // static StrokeAlign get strokeAlignCenter => StrokeAlign.center;
  // static StrokeAlign get strokeAlignOutside => StrokeAlign.outside;
}


