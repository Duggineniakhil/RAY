import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  Future<void> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (e) {},
      onStatus: (s) {},
    );
  }

  Future<String?> listenForCommand() async {
    if (!_isAvailable) {
      await initialize();
      if (!_isAvailable) return null;
    }

    String? result;
    await _speech.listen(
      onResult: (r) {
        if (r.finalResult) result = r.recognizedWords;
      },
      listenFor: const Duration(seconds: 5),
      localeId: 'en_US',
    );

    // Wait for listen to complete
    await Future.delayed(const Duration(seconds: 6));
    await _speech.stop();

    return _parseCommand(result);
  }

  String? _parseCommand(String? input) {
    if (input == null || input.isEmpty) return null;
    final lower = input.toLowerCase();

    // Common patterns: "show comedy", "search travel", etc.
    final triggers = ['show', 'search', 'find', 'play'];
    for (final trigger in triggers) {
      if (lower.contains(trigger)) {
        final query = lower
            .replaceAll(trigger, '')
            .replaceAll('videos', '')
            .replaceAll('video', '')
            .trim();
        return query.isNotEmpty ? query : input;
      }
    }
    return input;
  }

  Future<void> stop() => _speech.stop();
  bool get isListening => _speech.isListening;
}
