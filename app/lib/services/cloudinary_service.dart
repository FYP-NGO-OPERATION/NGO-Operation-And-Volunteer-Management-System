import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  // Cloudinary credentials extracted from .env file
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  // SECURE: Replaced signed uploads with unsigned upload preset. Secrets removed from client.
  static const String _uploadPreset = 'ngo_unsigned_preset';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      return await uploadImageBytes(await imageFile.readAsBytes());
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      return null;
    }
  }

  static Future<String?> uploadImageBytes(
    Uint8List imageBytes, {
    String? filename,
  }) async {
    try {
      // Unsigned upload does not need api_key or signature
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: filename ?? 'upload.file',
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        debugPrint('Cloudinary Upload Success: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      return null;
    }
  }
}
