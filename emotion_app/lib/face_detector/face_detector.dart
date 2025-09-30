import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'detector.dart';
import 'face_painter.dart';
import 'model_prediction.dart';
import 'util/rect_from_faces.dart';
class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  final modelPrediction = ModelPrediction();

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    List<int> predictions = [];
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // for (final face in faces) {
      //   Rect rect = rectFromFaces(
      //     face,
      //     inputImage.metadata!.size,
      //     inputImage.metadata!.size,
      //     inputImage.metadata!.rotation,
      //     _cameraLensDirection,
      //   );

      //   final img.Image? originalImage = img.decodeImage(inputImage.bytes!);
      //   if (originalImage == null) return null;
  
      //   // Crop the image to the detected face rectangle
      //   final img.Image croppedImage = img.copyCrop(
      //     originalImage,
      //     x: rect.left.toInt(),
      //     y: rect.top.toInt(),
      //     width: rect.width.toInt(),
      //     height: rect.height.toInt(),
      //   );
        
      //   //final prediction = modelPrediction.predictImage(croppedImage);
      //   //predictions.add(_argmax(prediction));
      // }  
      
      final painter = FaceDetectorPainter(
        faces,
        //predictions,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        inputImage,
        modelPrediction,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}