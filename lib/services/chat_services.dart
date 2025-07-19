import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:japx/japx.dart';
import 'package:myfliq_app/model/chat_model.dart';
import 'package:myfliq_app/model/chat_user_model.dart';
import 'package:myfliq_app/model/params.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches the list of users available for chat.
Future<List<ChatUser>> fetchChatUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('❌ Access token is missing');
  }

  final response = await http.get(
    Uri.parse(
      'https://test.myfliqapp.com/api/v1/chat/chat-messages/queries/contact-users',
    ),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/vnd.api+json',
    },
  );

  print("📡 Status Code: ${response.statusCode}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> decodedJson = jsonDecode(response.body);
    final Map<String, dynamic> japxDecoded = Japx.decode(decodedJson);
    final List<dynamic> data = japxDecoded['data'];

    return data.map((user) => ChatUser.fromJapx(user)).toList();
  } else {
    throw Exception(
      '❌ Failed to load chat users. Status: ${response.statusCode}',
    );
  }
}

/// Riverpod provider for fetching chat messages between two users
final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, ChatParams>((
  ref,
  params,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token') ?? '';

  final senderId = params.senderId;
  final receiverId = params.receiverId;

  final url = Uri.parse(
    'https://test.myfliqapp.com/api/v1/chat/chat-messages/queries/chat-between-users/$receiverId/$senderId',
  );

  print("📤 Fetching messages between $senderId and $receiverId");
  print("📡 GET: $url");

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.api+json',
    },
  );

  print("📥 Status Code: ${response.statusCode}");
  print("📥 Response Body: ${response.body}");

  if (response.statusCode == 200) {
    final decodedJson = jsonDecode(response.body);
    final japxDecoded = Japx.decode(decodedJson);

    final List<dynamic> data = japxDecoded['data'];
    final List<dynamic> included = decodedJson['included'] ?? [];

    // 🔧 Build map of included data
    final Map<String, Map<String, dynamic>> includedMap = {
      for (var item in included) '${item['type']}_${item['id']}': item,
    };

    return data.map((e) {
      final senderIdStr = e['sender_id']?.toString() ?? '';
      final senderType = e['sender_type'] ?? 'sender';
      final senderKey = '${senderType}_$senderIdStr';
      final includedSender = includedMap[senderKey];
      return ChatMessage.fromJapx(e, includedSender);
    }).toList();
    // ✅ no need for includedSender
  } else {
    throw Exception(
      '❌ Failed to fetch chat messages. Status: ${response.statusCode}',
    );
  }
});
