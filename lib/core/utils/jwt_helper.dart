import 'dart:convert';

class JwtHelper {
  static Map<String, dynamic> decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token');
      }

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decodedPayload = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decodedPayload);
    } catch (e) {
      print('Error decoding JWT token: $e');
      return {};
    }
  }

  static bool isTokenExpired(String token) {
    try {
      final decodedToken = decodeJWT(token);
      final exp = decodedToken['exp'];

      if (exp == null) return false;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }
}
