import 'dart:async';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'util/preprocess_image.dart';

class ModelPrediction {
  late Interpreter? _interpreter;
  late IsolateInterpreter? _isolateInterpreter;
  final _resultController = StreamController<Map<int, Object>>.broadcast();
  Completer<void>? _inferenceCompleter;
  bool _isProcessing = false;
  ModelPrediction() {
    _loadModel();
  }

  Future<void> dispose() async {
    
    if (_inferenceCompleter != null && !_inferenceCompleter!.isCompleted) {
      await _inferenceCompleter!.future.catchError((_) {}); 
    }
    await _resultController.close();
    _isolateInterpreter?.close();
    
    
  }

  void _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _isolateInterpreter = await IsolateInterpreter.create(address: _interpreter!.address);
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Stream<Map<int, Object>> get results => _resultController.stream;
  

  Future<void> predictImage(InputImage image, List<Face> faces) async {
    
    if (_isProcessing) {
      return; 
    }
    _isProcessing = true;
    _inferenceCompleter = Completer<void>();
    var processedImages = preprocessImage(image, faces);
    var output = {for (var i = 0; i < processedImages.length; i++) i: List.filled(5, 0.0).reshape([1, 5])};
    // if (_interpreter == null) {
    //   return {0: List.filled(5, 0.0).reshape([1, 5])};
    // }

    try{
      await _isolateInterpreter!.runForMultipleInputs(processedImages, output);
      _resultController.add(output);
    }finally{
      _inferenceCompleter?.complete();
      _isProcessing = false;
    }
    
    
    //return output;

  }



}