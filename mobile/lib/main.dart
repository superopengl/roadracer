import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        KeyEvent,
        KeyUpEvent,
        LogicalKeyboardKey,
        rootBundle,
        SystemChrome,
        SystemUiMode;
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
  late final WebViewController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A1A));
    _loadGame();
  }

  Future<void> _loadGame() async {
    final html = await rootBundle.loadString('assets/RoadRacerGame.html');
    await _controller.loadHtmlString(html, baseUrl: 'about:blank');
    if (mounted) setState(() => _ready = true);
  }

  // Flutter's default focus traversal swallows arrow keys before they reach
  // WKWebView, so the in-page JS never sees them. Forward arrow keys to the
  // WebView as synthetic KeyboardEvents so the game's existing handlers fire.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final keyName = _arrowKeyName(event.logicalKey);
    if (keyName == null) return KeyEventResult.ignored;
    final type = event is KeyUpEvent ? 'keyup' : 'keydown';
    _controller.runJavaScript(
      "document.dispatchEvent(new KeyboardEvent('$type', "
      "{key: '$keyName', bubbles: true}));",
    );
    return KeyEventResult.handled;
  }

  static String? _arrowKeyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return 'ArrowUp';
    if (key == LogicalKeyboardKey.arrowDown) return 'ArrowDown';
    if (key == LogicalKeyboardKey.arrowLeft) return 'ArrowLeft';
    if (key == LogicalKeyboardKey.arrowRight) return 'ArrowRight';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: !_ready
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              )
            : Focus(
                autofocus: true,
                onKeyEvent: _onKeyEvent,
                child: WebViewWidget(controller: _controller),
              ),
      ),
    );
  }
}
