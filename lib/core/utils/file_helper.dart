import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports
import 'dart:io' if (dart.library.html) 'dart:html' as io;

class FileHelper {
  static Future<Uint8List> readFileAsBytes(String filePath) async {
    if (kIsWeb) {
      // For web, we can't read files directly by path
      // This will be handled differently in the UI layer
      throw UnsupportedError('File reading by path not supported on web');
    } else {
      // For mobile/desktop
      final file = io.File(filePath);
      return await file.readAsBytes();
    }
  }

  static String getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }
}
