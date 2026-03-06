import 'dart:async';
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

  /// Listens for a voice command and returns the parsed query.
  /// Uses a Completer that resolves as soon as the speech engine
  /// produces a final result or times out — no fixed 6-second delay.
  Future<String?> listenForCommand() async {
    if (!_isAvailable) {
      await initialize();
      if (!_isAvailable) return null;
    }

    final completer = Completer<String?>();
    String? captured;

    await _speech.listen(
      onResult: (r) {
        if (r.recognizedWords.isNotEmpty) {
          captured = r.recognizedWords;
        }
        if (r.finalResult && !completer.isCompleted) {
          completer.complete(_parseCommand(captured));
        }
      },
      onSoundLevelChange: null,
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_US',
    );

    // Re-initialize with status listener so we catch done/notListening
    _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') &&
            !completer.isCompleted) {
          completer.complete(_parseCommand(captured));
        }
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete(_parseCommand(captured));
        }
      },
    );

    // Safety timeout — never hang forever
    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete(_parseCommand(captured));
      }
    });

    final result = await completer.future;
    await _speech.stop();
    return result;
  }

  String? _parseCommand(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final lower = input.toLowerCase().trim();

    // Strip common trigger words and return the query topic
    final triggers = ['show', 'search', 'find', 'play', 'look for'];
    for (final trigger in triggers) {
      if (lower.startsWith(trigger)) {
        final query = lower
            .substring(trigger.length)
            .replaceAll('videos', '')
            .replaceAll('video', '')
            .trim();
        return query.isNotEmpty ? query : lower;
      }
    }
    // Return the raw input if no trigger keyword
    return lower
        .replaceAll('videos', '')
        .replaceAll('video', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> stop() => _speech.stop();
  bool get isListening => _speech.isListening;
}
