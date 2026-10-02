import 'package:dio/dio.dart';

class SunyaAiGateway {
  SunyaAiGateway({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'SUNYA_API_URL',
              defaultValue: '',
            );

  final Dio _dio;
  final String _baseUrl;

  bool get configured => _baseUrl.trim().isNotEmpty;

  Future<String?> chat({
    required String message,
    String provider = 'sunya',
    Map<String, dynamic> context = const {},
    String? idToken,
  }) async {
    if (!configured) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/v1/ai/chat',
        data: {
          'message': message,
          'provider': provider,
          'context': context,
        },
        options: Options(
          headers: {
            if (idToken != null && idToken.isNotEmpty)
              'Authorization': 'Bearer $idToken',
          },
        ),
      );
      return response.data?['text'] as String?;
    } catch (_) {
      return null;
    }
  }
}
