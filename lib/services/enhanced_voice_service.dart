import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnhancedVoiceService {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _lastLocaleId = '';

  bool get isAvailable => _available;
  bool get isListening => _listening;

  Future<bool> initialize() async {
    try {
      _available = await _stt.initialize(
        onError: (e) => debugPrint('STT error: $e'),
        onStatus: (s) => debugPrint('STT status: $s'),
      );
      if (_available) {
        final locales = await _stt.locales();
        _lastLocaleId = locales.first.localeId;
      }
      return _available;
    } catch (_) {
      _available = false;
      return false;
    }
  }

  Future<void> start({
    required void Function(String text) onResult,
    String? localeId,
  }) async {
    if (!_available) {
      _available = await initialize();
      if (!_available) return;
    }
    _listening = true;
    await _stt.listen(
      localeId: localeId ?? _lastLocaleId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      onResult: (r) {
        if (!r.finalResult && (r.recognizedWords).isEmpty) return;
        onResult(r.recognizedWords);
      },
    );
  }

  Future<void> stop() async {
    if (!_listening) return;
    _listening = false;
    await _stt.stop();
  }

  Future<void> cancel() async {
    _listening = false;
    await _stt.cancel();
  }
}

/// A compact FAB button that starts/stops listening and returns the transcript
/// via onCommand callback.
class VoiceCommandButton extends StatefulWidget {
  final ValueChanged<String> onCommand;
  final String prompt;
  final String? tooltip;

  const VoiceCommandButton({
    super.key,
    required this.onCommand,
    required this.prompt,
    this.tooltip,
  });

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  final _voice = EnhancedVoiceService();
  late AnimationController _pulseController;
  String _buffer = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _voice.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voice.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_voice.isListening) {
      await _voice.stop();
      if (_buffer.trim().isNotEmpty) {
        widget.onCommand(_buffer.trim());
        _buffer = '';
      }
      setState(() {});
      return;
    }
    _buffer = '';
    await _voice.start(onResult: (text) {
      setState(() => _buffer = text);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final listening = _voice.isListening;
    return Tooltip(
      message: widget.tooltip ?? 'Voice',
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (listening)
            SizedBox(
              width: 72,
              height: 72,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red
                          .withOpacity(0.2 + 0.2 * _pulseController.value),
                    ),
                  );
                },
              ),
            ),
          FloatingActionButton(
            onPressed: _toggle,
            child: Icon(listening ? Icons.stop : Icons.mic),
          ),
        ],
      ),
    );
  }
}
