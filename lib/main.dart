import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        )),
    'voice': HighlightedWord(
        onTap: () => print('voice'),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        )),
    'subcribe': HighlightedWord(
        onTap: () => print('subcribe'),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        )),
    'like': HighlightedWord(
        onTap: () => print('like'),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        )),
    'comment': HighlightedWord(
        onTap: () => print('comment'),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        )),
  };
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Confidences: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
        // actions: [
        //   Builder(builder: (context) {
        //     return IconButton(
        //         onPressed: () async {
        //           await FlutterClipboard.copy(_text);
        //           ScaffoldMessenger.of(context).showSnackBar(
        //               const SnackBar(content: Text(' Copied to Clipboard')));
        //         },
        //         icon: const Icon(Icons.content_copy));
        //   }),
        // ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
          endRadius: 75.0,
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none))),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
                fontSize: 32, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) {
          print('onError: $val');
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _text = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
