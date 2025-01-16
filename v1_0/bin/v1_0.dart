import 'package:v1_0/expirement/tests.dart' as test;
import 'package:v1_0/v1_0.dart' as v1_0;

void main(List<String> arguments) {
  var field = v1_0.Field(80);
  field.randomInit();
  for (int i = 0; i < 80; i++) {
    field.visualize(i);
    field.iter(1);
  }
  field.toVideo("output/video/test2.mp4", 1);
}
