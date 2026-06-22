import '../../../core/network/api_client.dart';

class FitnessBuddyApi {
  static Future<int> startChat({required int userId}) async {
    final data = await ApiClient.post('/chat/chats/start/$userId');

    if (data['success'] != true) {
      throw Exception(
        ApiClient.asString(data['message']).isEmpty
            ? 'Failed to start chat.'
            : ApiClient.asString(data['message']),
      );
    }

    return ApiClient.asInt(data['chat_id']);
  }

  static Future<List<Map<String, dynamic>>> getMessages({
    required int chatId,
  }) async {
    final data = await ApiClient.get('/chat/messages/$chatId');

    if (data['success'] != true) {
      throw Exception(
        ApiClient.asString(data['message']).isEmpty
            ? 'Failed to load messages.'
            : ApiClient.asString(data['message']),
      );
    }

    final List messages = data['messages'] ?? [];

    return messages.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int userId,
    required int? chatId,
    required String content,
  }) async {
    final data = await ApiClient.post(
      '/chat/reply/$userId',
      body: {'content': content, 'chat_id': chatId},
    );

    if (data['success'] != true) {
      final statusCode = ApiClient.asInt(data['statusCode']);

      if (statusCode == 404) {
        throw Exception(
          'AI chat endpoint was not found. Please deploy POST /chat/reply/{user_id} in FastAPI.',
        );
      }

      throw Exception(
        ApiClient.asString(data['message']).isEmpty
            ? 'Failed to send message.'
            : ApiClient.asString(data['message']),
      );
    }

    return data;
  }

  static Future<void> deleteMessage({required int messageId}) async {
    final data = await ApiClient.delete('/chat/messages/$messageId');

    if (data['success'] != true) {
      throw Exception(
        ApiClient.asString(data['message']).isEmpty
            ? 'Failed to delete message.'
            : ApiClient.asString(data['message']),
      );
    }
  }

  static Future<void> deleteAllMessages({required int chatId}) async {
    final data = await ApiClient.delete('/chat/messages/chat/$chatId');

    if (data['success'] != true) {
      throw Exception(
        ApiClient.asString(data['message']).isEmpty
            ? 'Failed to delete conversation.'
            : ApiClient.asString(data['message']),
      );
    }
  }
}
