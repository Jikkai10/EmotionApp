import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

Rect rectFromFaces(
  Face face,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  final left = translateX(
    face.boundingBox.left,
    canvasSize,
    imageSize,
    rotation,
    cameraLensDirection,
  );
  final top = translateY(
    face.boundingBox.top,
    canvasSize,
    imageSize,
    rotation,
    cameraLensDirection,
  );
  final right = translateX(
    face.boundingBox.right,
    canvasSize,
    imageSize,
    rotation,
    cameraLensDirection,
  );
  final bottom = translateY(
    face.boundingBox.bottom,
    canvasSize,
    imageSize,
    rotation,
    cameraLensDirection,
  );

  return Rect.fromLTRB(left, top, right, bottom);
}