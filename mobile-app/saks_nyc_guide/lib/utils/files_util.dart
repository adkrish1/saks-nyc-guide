import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FilesUtil {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/messages.txt');
  }

  Future<String> readFile() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }

  void writeToFile(String fileContents) async {
    final file = await _localFile;
    file.writeAsStringSync(fileContents);
  }
}
