import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


class ModelPrediction {
  late Interpreter _interpreter;

  ModelPrediction() {
    _loadModel();
  }

  void _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }
  List<double> predictImage(img.Image image) {
    
    final int targetSize = 48; 
    final img.Image resizedImage = img.copyResize(
      image,
      width: targetSize,
      height: targetSize,
    );

    final input = Float32List(targetSize * targetSize * 1); // Grayscale
    int pixelIndex = 0;
    
    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        
        final intensity = img.getLuminance(pixel).toDouble();
        input[pixelIndex++] = intensity / 255.0;
        
      }
    }
    
    var output = List.filled(1 * 5, 0.0).reshape([1, 5]);
    
    _interpreter.run(input.reshape([1, targetSize, targetSize, 1]), output);

    return output[0];

  }



}