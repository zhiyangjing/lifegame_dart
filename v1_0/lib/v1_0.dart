import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

class Field {
  late List<List<bool>> _data;
  late int _rowNum, _columnNum;
  static const height = 1080;
  static const width = 1920;
  late double _blockWidth, _blockHeight;

  final imageOutputDir = Directory('./output/images');

  /// If the second parameter is left empty the appropriate number of columns will be
  /// automatically selected based on the number of rows to ensure the blocks are
  /// close to square-shaped
  Field(int rowNum, [int columnNum = -1]) {
    _rowNum = rowNum;
    _blockHeight = height / rowNum;
    if (columnNum < 0) {
      _columnNum = width ~/ _blockHeight;
      _blockWidth = width / _columnNum;
    } else {
      _columnNum = columnNum;
      _blockWidth = width / columnNum;
    }
    print("RowNum: $_rowNum, ColumnNum: $_columnNum");
    print("BlockHeight: $_blockHeight, BlockWidth: $_blockWidth");

    _data = List.generate(_rowNum, (index) => List.filled(_columnNum, false));
  }

  void iter(int times) {
    for (int i = 0; i < times; i++) {
      _data = nextState();
    }
  }

  // The blocks at the edges will be set to 0
  List<List<bool>> nextState() {
    List<List<bool>> newData = List.generate(_rowNum, (index) => List.filled(_columnNum, false));
    void setValue(total, i, j) {
      if (total == 3) {
        newData[i][j] = true;
      } else if (total == 4) {
        newData[i][j] = _data[i][j];
      } else {
        newData[i][j] = false;
      }
    }

    for (int i = 1; i < _rowNum - 1; i++) {
      for (int j = 1; j < _columnNum - 1; j++) {
        int total = _data
            .sublist(i - 1, i + 2)
            .fold(0, (x, y) => x + y.sublist(j - 1, j + 2).fold(0, (a, b) => a + (b ? 1 : 0)));
        setValue(total, i, j);
      }
    }

    // TODO: Implement the loop boundaries.

    return newData;
  }

  void randomInit() {
    Random random = Random();
    for (int i = 0; i < _rowNum; i++) {
      for (int j = 0; j < _columnNum; j++) {
        _data[i][j] = random.nextBool();
      }
    }
  }

  void visualize([int no = 0]) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    for (int i = 0; i < _rowNum; i++) {
      for (int j = 0; j < _columnNum; j++) {
        if (_data[i][j]) {
          img.fillRect(image,
              x1: (j * _blockWidth).toInt(),
              y1: (i * _blockHeight).toInt(),
              x2: ((j + 1) * _blockWidth).toInt(),
              y2: ((i + 1) * _blockHeight).toInt(),
              color: img.ColorRgb8(0, 0, 0));
        }
      }
    }
    if (!imageOutputDir.existsSync()) {
      print("Image output dir not exist");
      imageOutputDir.createSync(recursive: true);
    }
    final file = File("${imageOutputDir.path}/frame_${no.toString().padLeft(3, '0')}.png");
    file.writeAsBytesSync(img.encodePng(image));
    print("Image write successfully");
  }

  Future<void> toVideo(String outputVideoPath, int fps) async {
    final videoOutputDir = Directory(outputVideoPath).parent;
    if (!videoOutputDir.existsSync()) {
      print("Video output dir not exist");
      videoOutputDir.createSync(recursive: true);
    }

    final command = [
      'ffmpeg',
      '-framerate',
      '$fps',
      '-i',
      'output/images/frame_%03d.png',
      '-c:v',
      'libx264',
      '-pix_fmt',
      'yuv420p',
      '-y',
      outputVideoPath
    ];

    final process = await Process.start(command[0], command.sublist(1));

    process.stdout.listen((data) {
      print(String.fromCharCodes(data));
    });

    process.stderr.listen((data) {
      print(String.fromCharCodes(data));
    });

    await process.exitCode;
    print("Video created successfully at $outputVideoPath");
  }
}
