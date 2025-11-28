import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; 

class StreamScreen extends StatefulWidget {
  final String channelName; 

  const StreamScreen({super.key, required this.channelName});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController();

    // Configuración especial para que no falle en Web
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setBackgroundColor(const Color(0x00000000));
    }

    // Cargamos el player de Kick
    _controller.loadRequest(Uri.parse('https://player.kick.com/${widget.channelName}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Viendo a ${widget.channelName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      // Aquí se muestra el video incrustado
      body: WebViewWidget(controller: _controller),
    );
  }
}
