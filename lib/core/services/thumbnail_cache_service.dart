import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ThumbnailCacheService {
  static final ThumbnailCacheService _instance = ThumbnailCacheService._internal();
  factory ThumbnailCacheService() => _instance;
  ThumbnailCacheService._internal();

  Future<File?> getThumbnail(String url) async {
    if (url.isEmpty) return null;

    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/thumbnails');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final filename = md5.convert(utf8.encode(url)).toString();
    final file = File('${cacheDir.path}/$filename.jpg');

    if (await file.exists()) {
      return file;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (_) {}

    return null;
  }

  Future<void> clearCache() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/thumbnails');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}
