import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceCommandWidget extends StatefulWidget {
  final Function(String) onCommand;

  const VoiceCommandWidget({Key? key, required this.onCommand})
    : super(key: key);

  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'es_BO', // Cambia según tu país, ej: 'es_ES', 'es_MX'
        onResult: (result) {
          setState(() => _text = result.recognizedWords);
          widget.onCommand(result.recognizedWords);
        },
      );
    } else {
      setState(() => _text = 'No se pudo inicializar el micrófono');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _text.isEmpty ? 'Presiona el micrófono y habla...' : _text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(
            _isListening ? Icons.stop : Icons.mic,
            color: Colors.deepPurple,
          ),
          onPressed: _isListening ? _stopListening : _startListening,
        ),
      ],
    );
  }
}
