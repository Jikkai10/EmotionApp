import 'dart:typed_data';
import 'package:emotion_app/face_detector/util/decode_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

List<Object> preprocessImage(InputImage image, List<Face> faces) {

  img.Image decodedImage;
  List<Object> processImage = [];
  if (image.metadata?.format == InputImageFormat.bgra8888) {
    decodedImage = decodeBGRA8888(image);
  } else if (image.metadata?.format == InputImageFormat.nv21) {
    decodedImage = decodeYUV420SP(image);
  } else {
    return [];
  }
  for (var face in faces) {
    final img.Image croppedImage = img.copyCrop(
      decodedImage,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt().abs(),
      height: face.boundingBox.height.toInt().abs(),
    );
   
    final int targetSize = 48; 
    final img.Image resizedImage = img.copyResize(
      croppedImage,
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

    processImage.add(input.reshape([1, targetSize, targetSize, 1]));

  }
  return processImage;
}