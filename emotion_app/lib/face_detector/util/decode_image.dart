
import 'dart:typed_data';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;



img.Image decodeBGRA8888(InputImage image) {
    final width = image.metadata!.size.width.toInt();
    final height = image.metadata!.size.height.toInt();

    final Uint8List bgra8888 = image.bytes!; // actually it is ARGB!!!
    final Uint8List rgba8888 = Uint8List(width * height * 4);

    for (int i = 0, j = 0; i < bgra8888.length; i += 4, j += 4) {
      rgba8888[j] = bgra8888[i + 1]; // R
      rgba8888[j + 1] = bgra8888[i + 2]; // G
      rgba8888[j + 2] = bgra8888[i + 3]; // B
      rgba8888[j + 3] = bgra8888[i + 0]; // A
    }

    img.Image outImg = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgba8888.buffer,
      order: img.ChannelOrder.rgba,
    );

    switch (image.metadata!.rotation) {
      case InputImageRotation.rotation0deg:
        return img.copyRotate(outImg, angle: 0);
      case InputImageRotation.rotation90deg:
        return img.copyRotate(outImg, angle: 90);
      case InputImageRotation.rotation180deg:
        return img.copyRotate(outImg, angle: 180);
      case InputImageRotation.rotation270deg:
        return img.copyRotate(outImg, angle: 270);
      
    }
  }
  
  
  img.Image decodeYUV420SP(InputImage image) {
    final width = image.metadata!.size.width.toInt();
    final height = image.metadata!.size.height.toInt();

    final yuv420sp = image.bytes!;
   
    final outImg = img.Image(width: width, height: height, numChannels: 4);
    final outBytes = outImg.getBytes();
    // View the image data as a Uint32List.
    final rgba = Uint32List.view(outBytes.buffer);

    final frameSize = width * height;

    for (var j = 0, yp = 0; j < height; j++) {
      var uvp = frameSize + (j >> 1) * width;
      var u = 0;
      var v = 0;
      for (int i = 0; i < width; i++, yp++) {
        var y = (0xff & (yuv420sp[yp])) - 16;
        if (y < 0) {
          y = 0;
        }
        if ((i & 1) == 0) {
          v = (0xff & yuv420sp[uvp++]) - 128;
          u = (0xff & yuv420sp[uvp++]) - 128;
        }

        final y1192 = 1192 * y;
        var r = (y1192 + 1634 * v);
        var g = (y1192 - 833 * v - 400 * u);
        var b = (y1192 + 2066 * u);

        if (r < 0) {
          r = 0;
        } else if (r > 262143) {
          r = 262143;
        }
        if (g < 0) {
          g = 0;
        } else if (g > 262143) {
          g = 262143;
        }
        if (b < 0) {
          b = 0;
        } else if (b > 262143) {
          b = 262143;
        }

        // Write directly into the image data
        rgba[yp] = 0xff000000 | ((b << 6) & 0xff0000) | ((g >> 2) & 0xff00) | ((r >> 10) & 0xff);
      }
    }

    switch (image.metadata!.rotation) {
      case InputImageRotation.rotation0deg:
        return img.copyRotate(outImg, angle: 0);
      case InputImageRotation.rotation90deg:
        return img.copyRotate(outImg, angle: 90);
      case InputImageRotation.rotation180deg:
        return img.copyRotate(outImg, angle: 180);
      case InputImageRotation.rotation270deg:
        return img.copyRotate(outImg, angle: 270);
    }
 
  }