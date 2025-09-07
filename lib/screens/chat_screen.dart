import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chat_service.dart';
import '../widgets/feature_guard.dart';
import '../core/feature_flags.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _chat = ChatService();
  final _messages = <_Msg>[];
  late stt.SpeechToText _stt;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _stt = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NDIS Assistant'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'call', child: Text('Call NDIA 1800 800 110')),
              PopupMenuItem(value: 'email', child: Text('Email NDIA enquiries@ndis.gov.au')),
            ],
            onSelected: (v) => _escalate(v),
          )
        ],
      ),
      body: FeatureGuard(
        tier: FeatureTier.premium,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.mine ? Colors.indigo.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    tooltip: _listening ? 'Stop listening' : 'Voice input',
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleListening,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Ask a question about NDIS...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _escalate(String v) async {
    if (v == 'call') {
      await _launch('tel:1800800110');
    } else if (v == 'email') {
      await _launch('mailto:enquiries@ndis.gov.au?subject=NDIS%20Connect%20support');
    }
  }

  Future<void> _launch(String url) async {
    final ok = await canLaunchUrl(Uri.parse(url));
    if (ok) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _stt.initialize();
    if (!available) return;
    setState(() => _listening = true);
    _stt.listen(onResult: (r) {
      setState(() => _controller.text = r.recognizedWords);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
    });
    final reply = await _chat.ask(text);
    if (!mounted) return;
    setState(() => _messages.add(_Msg(reply, false)));
  }
}

class _Msg {
  final String text;
  final bool mine;
  _Msg(this.text, this.mine);
}
