import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  final String name;

  FileStorage(this.name);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$name.txt');
  }

  Future<File> reset() async {
    final file = await _localFile;
    return file.writeAsString("");
  }

  Future<File> write(String text) async {
    final file = await _localFile;
    return file.writeAsString(text);
  }

  Future<String> read() async {
    try {
      final file = await _localFile;
      var content = await file.readAsString();

      return content;
    } catch (e) {
      return "";
    }
  }
}
