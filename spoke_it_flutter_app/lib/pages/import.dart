import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> read(String file_path) async {
  String text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('file_path');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
    text = "";
  }
  return text;
}
