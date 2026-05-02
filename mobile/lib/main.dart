import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, SystemChrome, SystemUiMode;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const RoadracerApp());
}

class RoadracerApp extends StatelessWidget {
  const RoadracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Road Racer',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Future<WebViewController> _controllerFuture = _buildController();

  Future<WebViewController> _buildController() async {
    final html = await rootBundle.loadString('assets/Roadracer.html');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A1A))
      ..loadHtmlString(html, baseUrl: 'about:blank');
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: FutureBuilder<WebViewController>(
          future: _controllerFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              );
            }
            return WebViewWidget(controller: snapshot.data!);
          },
        ),
      ),
    );
  }
}
