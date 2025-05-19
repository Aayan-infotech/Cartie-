import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFApi {
  static Future<File> loadNetworkPDF(String url, fileName) async {
    var respons = await http.get(Uri.parse(url));
    final bytes = respons.bodyBytes;
    return _storeFile(url, bytes, fileName);
  }

  static Future<File> _storeFile(String url, bytes, basename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$basename');
    await file.writeAsBytes(bytes, flush: true, mode: FileMode.write);
    return file;
  }

  static Future<void> saveFileToLocalDirectory(
      String str, String fileName) async {
    if (kIsWeb) {
      return; // Don't do anything on web
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsString(str, flush: true, mode: FileMode.write);
    } catch (e) {
      print('Error saving file to local directory: $e');
    }
  }

  // static Future<bool> checkIfFileExists(path) async {
  //   if (kIsWeb) {
  //     return false;
  //   }

  //   final dir = await getApplicationDocumentsDirectory();
  //   return await File('${dir.path}/$path').exists();
  // }
  static Future<bool> checkIfFileExists(String path) async {
    try {
      if (kIsWeb) {
        return false;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$path');

      // Check if file exists
      return await file.exists();
    } catch (e) {
      // Handle any exceptions that occur during the file check
      print('Error checking if file exists: $e');
      return false;
    }
  }

  static Future<String> readFileFromLocalDirectory(path) async {
    final dir = await getApplicationDocumentsDirectory();
    return await File('${dir.path}/$path').readAsString();
  }

  static Future deleteFile(path) async {
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/$path').delete();
    }
  }
}
