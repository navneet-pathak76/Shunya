class AiRequest {
  const AiRequest({required this.message, this.context = const <String, Object?>{}});

  final String message;
  final Map<String, Object?> context;
}

class AiResponse {
  const AiResponse({required this.text});

  final String text;
}

abstract interface class AiService {
  Future<AiResponse> complete(AiRequest request);
}
