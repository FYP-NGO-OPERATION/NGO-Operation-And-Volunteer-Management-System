import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  // Cloudinary credentials extracted from .env file
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      return await uploadImageBytes(await imageFile.readAsBytes());
    } catch (e) {
      print('Cloudinary Exception: $e');
      return null;
    }
  }

  static Future<String?> uploadImageBytes(Uint8List imageBytes, {String? filename}) async {
    try {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      // Generate SHA-1 signature: timestamp=1234567890<API_SECRET>
      final signatureString = 'timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(signatureString)).toString();

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: filename ?? 'upload.jpg'));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        print('Cloudinary Upload Success: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary Error: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Exception: $e');
      return null;
    }
  }
}
