import 'package:dio/dio.dart';
import 'sunya_ai_settings.dart';

enum SunyaAiProvider { sunya, chatgpt, gemini, claude }

extension SunyaAiProviderX on SunyaAiProvider {
  String get key => switch (this) {
        SunyaAiProvider.sunya => 'sunya',
        SunyaAiProvider.chatgpt => 'chatgpt',
        SunyaAiProvider.gemini => 'gemini',
        SunyaAiProvider.claude => 'claude',
      };

  String get label => switch (this) {
        SunyaAiProvider.sunya => 'SUNYA AI',
        SunyaAiProvider.chatgpt => 'ChatGPT',
        SunyaAiProvider.gemini => 'Gemini',
        SunyaAiProvider.claude => 'Claude',
      };
}

class SunyaAiGateway {
  SunyaAiGateway({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment('SUNYA_API_URL', defaultValue: '');

  final Dio _dio;
  final String _baseUrl;

  bool get configured => _baseUrl.trim().isNotEmpty;

  Future<String?> chat({
    required String message,
    required SunyaAiProvider provider,
    Map<String, dynamic> context = const {},
  }) async {
    if (!configured) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/v1/ai/chat',
        data: {
          'message': message,
          'provider': provider.key,
          'context': context,
        },
      );
      return response.data?['text'] as String?;
    } catch (_) {
      return null;
    }
  }
}
