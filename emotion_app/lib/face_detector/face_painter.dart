import 'dart:math';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;
import 'util/coordinates_translator.dart';
import 'util/rect_from_faces.dart';
import 'model_prediction.dart';
import 'util/decodeImage.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.inputImage,
    this.modelPrediction,
  );

  final List<Face> faces;
  final InputImage inputImage;
  final ModelPrediction modelPrediction;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  int _argmax(List<double> list) {
    double maxValue = list[0];
    int maxIndex = 0;

    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }
  List<String> emotions = [
    'Angry',
    'Happy',
    'Sad',
    'Surprise',
    'Neutral'
  ];
  List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.grey
  ];
  @override
  void paint(Canvas canvas, Size size)  async {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;
    
    for (final Face face in faces) {
      Rect rect = rectFromFaces(
        face,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      
      img.Image decodedImage;
      if (inputImage.metadata?.format == InputImageFormat.bgra8888) {
        decodedImage = decodeBGRA8888(inputImage);
      } else if (inputImage.metadata?.format == InputImageFormat.nv21) {
        decodedImage = decodeYUV420SP(inputImage);
      } else {
        return;
      }
      
      final img.Image croppedImage = img.copyCrop(
          decodedImage,
          x: face.boundingBox.left.toInt(),
          y: face.boundingBox.top.toInt(),
          width: face.boundingBox.width.toInt().abs(),
          height: face.boundingBox.height.toInt().abs(),
        );
      
      final prediction = modelPrediction.predictImage(croppedImage);
      int emotionIndex = 0;
      emotionIndex = _argmax(prediction); 
      
      
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Emotion: ${emotions[emotionIndex]}',
          style: TextStyle(color: colors[emotionIndex], fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(rect.right, rect.top - 20));
     
      paint1.color = colors[emotionIndex];
      canvas.drawRect(
        rect,
        paint1,
      );

      void paintContour(FaceContourType type) {
        final contour = face.contours[type];
        if (contour?.points != null) {
          for (final Point point in contour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1,
                paint1);
          }
        }
      }

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              paint2);
        }
      }

      for (final type in FaceContourType.values) {
        paintContour(type);
      }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}