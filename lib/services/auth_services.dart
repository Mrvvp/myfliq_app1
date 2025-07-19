import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:japx/japx.dart';

class AuthService {
  static const String baseUrl = 'https://test.myfliqapp.com/api/v1';

  static Future<int?> sendOtp(String phoneNumber) async {
    final url = Uri.parse(
      '$baseUrl/auth/registration-otp-codes/actions/phone/send-otp',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "data": {
          "type": "registration_otp_codes",
          "attributes": {"phone": phoneNumber},
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data['data']; // returns the OTP for testing
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final url = Uri.parse(
      '$baseUrl/auth/registration-otp-codes/actions/phone/verify-otp',
    );

    final body = {
      "data": {
        "type": "registration_otp_codes",
        "attributes": {
          "phone": phone,
          "otp": int.parse(otp),
          "device_meta": {
            "type": "mobile",
            "device-name": "iPhone",
            "device-os-version": "iOS 16.0",
            "browser": "N/A",
            "browser_version": "N/A",
            "user-agent": "FlutterApp",
            "screen_resolution": "390x844",
            "language": "en-IN",
          },
        },
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      final Map<String, dynamic> japxDecoded = Japx.decode(decodedJson);
      return japxDecoded['data'];
    } else {
      return null;
    }
  }
}
