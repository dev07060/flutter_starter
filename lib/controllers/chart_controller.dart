import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class _SfTrackShape extends SfTrackShape {
  _SfTrackShape(dynamic min, dynamic max) {
    this.min = (min.runtimeType == DateTime
        ? min.millisecondsSinceEpoch.toDouble()
        : min) as double;
    this.max = (max.runtimeType == DateTime
        ? max.millisecondsSinceEpoch.toDouble()
        : max) as double;
  }

  late double min;
  late double max;
  double? trackIntermediatePos;

  @override
  void paint(PaintingContext context, Offset offset, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Animation<double> enableAnimation,
      required Paint? inactivePaint,
      required Paint? activePaint,
      required TextDirection textDirection}) {
    final Rect trackRect = getPreferredRect(parentBox, themeData, offset);
    final double actualValue = (currentValue.runtimeType == DateTime
        ? currentValue.millisecondsSinceEpoch.toDouble()
        : currentValue) as double;
    final double actualValueInPercent =
        ((actualValue - min) * 100) / (max - min);
    trackIntermediatePos = _getTrackIntermediatePosition(trackRect);

    // low volume track.
    final Paint trackPaint = Paint();
    trackPaint.color = actualValueInPercent <= 80.0 ? Colors.green : Colors.red;
    final Rect lowVolumeRect = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter!.dx, trackRect.bottom);
    context.canvas.drawRect(lowVolumeRect, trackPaint);

    if (actualValueInPercent <= 80.0) {
      trackPaint.color = Colors.green.withOpacity(0.40);
      final Rect lowVolumeRectWithLessOpacity = Rect.fromLTRB(thumbCenter.dx,
          trackRect.top, trackIntermediatePos!, trackRect.bottom);
      context.canvas.drawRect(lowVolumeRectWithLessOpacity, trackPaint);
    }

    trackPaint.color = Colors.red.withOpacity(0.40);
    final double highTrackLeft =
        actualValueInPercent >= 80.0 ? thumbCenter.dx : trackIntermediatePos!;
    final Rect highVolumeRectWithLessOpacity = Rect.fromLTRB(highTrackLeft,
        trackRect.top, trackRect.width + trackRect.left, trackRect.bottom);
    context.canvas.drawRect(highVolumeRectWithLessOpacity, trackPaint);
  }

  double _getTrackIntermediatePosition(Rect trackRect) {
    final double actualValue = ((80 * (max - min)) + min) / 100;
    return (((actualValue - min) / (max - min)) * trackRect.width) +
        trackRect.left;
  }
}

class _SfThumbShape extends SfThumbShape {
  _SfThumbShape(dynamic min, dynamic max) {
    this.min = (min.runtimeType == DateTime
        ? min.millisecondsSinceEpoch.toDouble()
        : min) as double;
    this.max = (max.runtimeType == DateTime
        ? max.millisecondsSinceEpoch.toDouble()
        : max) as double;
  }

  late double min;
  late double max;

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final double actualValue = (currentValue.runtimeType == DateTime
        ? currentValue.millisecondsSinceEpoch.toDouble()
        : currentValue) as double;

    final double actualValueInPercent =
        ((actualValue - min) * 100) / (max - min);

    paint = Paint();
    paint.color = actualValueInPercent <= 80 ? Colors.green : Colors.red;

    super.paint(context, center,
        parentBox: parentBox,
        themeData: themeData,
        currentValue: currentValue,
        paint: paint,
        enableAnimation: enableAnimation,
        textDirection: textDirection,
        thumb: thumb,
        child: child);
  }
}
