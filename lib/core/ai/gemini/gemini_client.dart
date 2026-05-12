import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  final GenerativeModel _model;

  GeminiClient()
    : _model = GenerativeModel(
        model: 'gemini-3.1-flash-lite-preview',
        apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      );

  Future<String> generateText(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return _extractResponseText(response);
  }

  Future<String> generateTextFromImage({
    required String prompt,
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)]),
    ]);
    return _extractResponseText(response);
  }

  Map<String, dynamic> decodeJsonObject(String text) {
    return jsonDecode(_cleanJsonText(text)) as Map<String, dynamic>;
  }

  List<dynamic> decodeJsonArray(String text) {
    return jsonDecode(_cleanJsonText(text)) as List<dynamic>;
  }

  String _extractResponseText(GenerateContentResponse response) {
    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini 응답을 가져오지 못했습니다.');
    }

    return text.trim();
  }

  String _cleanJsonText(String text) {
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }
}
