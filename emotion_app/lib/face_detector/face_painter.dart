import 'dart:math';
import 'dart:ui';
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
    //this.predictions,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.inputImage,
    this.modelPrediction,
  );

  final List<Face> faces;
  //final List<int> predictions;
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
    'Disgust',
    'Fear',
    'Happy',
    'Sad',
    'Surprise',
    'Neutral'
  ];
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.grey
  ];
  @override
  void paint(Canvas canvas, Size size) {
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
      // final paragraph = ParagraphBuilder(
      //   ParagraphStyle(
      //     textAlign: TextAlign.left,
      //     fontSize: 12,
      //     textDirection: TextDirection.ltr,
      //   ),
      // )
      //   ..addText('Emotion: ');
      // final offset = Offset(rect.left, rect.top - 20);
      // canvas.drawParagraph(paragraph.build(), offset);
      // final img.Image originalImage = img.Image.fromBytes(
      //   width: inputImage.metadata!.size.width.toInt(),
      //   height: inputImage.metadata!.size.height.toInt(),
      //   bytes: inputImage.bytes!.buffer,
      //   format: img.Format.uint8,
      //   );
      img.Image decodedImage;
      if (inputImage.metadata?.format == InputImageFormat.bgra8888) {
        decodedImage = decodeBGRA8888(inputImage);
      } else if (inputImage.metadata?.format == InputImageFormat.nv21) {
        decodedImage = decodeYUV420SP(inputImage);
      } else {
        return;
      }

      //img.Image resizedImage = img.copyResize(decodedImage, width: inputImage.metadata!.size.width.toInt(), height: inputImage.metadata!.size.height.toInt());
      // Crop the image to the detected face rectangle
      
      final img.Image croppedImage = img.copyCrop(
          decodedImage,
          x: rect.left.toInt(),
          y: rect.top.toInt(),
          width: rect.width.toInt().abs(),
          height: rect.height.toInt().abs(),
        );
      final prediction = modelPrediction.predictImage(croppedImage);
      final emotionIndex = _argmax(prediction); 
      
      
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