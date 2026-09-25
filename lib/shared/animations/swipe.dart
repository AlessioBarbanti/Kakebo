import 'package:flutter/material.dart';

/// Direction a horizontal swipe asks for: -1 left, 1 right, 0 stay. A quick flick counts even when short.
int fling(DragEndDetails e, double dragged, double minDistance) {
  final v = e.velocity.pixelsPerSecond.dx;
  if (v.abs() > 500) return v.sign.toInt();
  return dragged.abs() > minDistance ? dragged.sign.toInt() : 0;
}
