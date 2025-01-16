import 'dart:io';

import 'package:image/image.dart' as img;

void gen_image_test() {
  // final image = img.Image(height: 1080,width: 1920);
  final image = img.Image(width: 1920, height: 1080);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  final pngBytes = img.encodePng(image);
  final file =  File("./output/image.png");
  final outputDir = Directory('./output');
  if (!outputDir.existsSync()) {
    print("output dir not exist");
    outputDir.createSync(recursive: true);
  }
  file.writeAsBytesSync(pngBytes);
  print("Image write successfully");
  // img.fill(image, img.getColor(255,255,255));
}
