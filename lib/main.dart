import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_size/window_size.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'dart:io';
import 'pages/home.dart';
import 'pages/screenshot.dart';
import 'pages/auth.dart';
import 'services/screenshot.dart';
import 'api/client.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(400, 300),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.setPreventClose(true);
  }

  await hotKeyManager.unregisterAll();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  String pageName = 'settingsPage';
  List<HotKey> _registeredHotKeyList = [];
  Uint8List? _screenshot;
  final ShotsClient shotsClient = ShotsClient();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initialize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (Platform.isWindows || Platform.isLinux) {
      await hideWindow();
    } else {
      super.onWindowClose();
    }
  }

  Future<void> hideWindow() async {
    if (Platform.isWindows || Platform.isLinux) {
      await windowManager.hide();
    } else {
      await windowManager.setSkipTaskbar(true);
      await windowManager.hide();
    }
  }

  Future<void> showWindow() async {
    await windowManager.setSkipTaskbar(false);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _initialize() async {
    await shotsClient.init();
    if (!(await shotsClient.checkToken())) {
      setState(() {
        pageName = 'authPage';
      });
    }
  }

  Future<void> makeShot() async {
    Uint8List? screenshot = await ScreenshotService.captureScreen();
    if (screenshot != null) {
      await showWindow();
      setState(() {
        _screenshot = screenshot;
        pageName = 'screenshotPage';
      });
    }
  }

  void _keyDownHandler(HotKey hotKey) async {
    await makeShot();
  }

  Future<void> _handleHotKeyRegister(HotKey hotKey) async {
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: _keyDownHandler,
    );
    setState(() {
      _registeredHotKeyList = hotKeyManager.registeredHotKeyList;
    });
  }

  void _changePage(String newPageName) {
    if (newPageName == 'screenshotPage') {
      hideWindow();
    }

    setState(() {
      pageName = newPageName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildCurrentPage(),
    );
  }

  Widget _buildCurrentPage() {
    switch (pageName) {
      case 'authPage':
        return AuthPage(
          changePage: _changePage,
          shotsClient: shotsClient,
        );
      case 'screenshotPage':
        return ScreenshotPage(
          screenshot: _screenshot,
          shotsClient: shotsClient,
          makeShot: makeShot,
        );
      case 'settingsPage':
      default:
        return HomePage(
          changePage: _changePage,
          onHotKeyRecorded: _handleHotKeyRegister,
          shotsClient: shotsClient,
        );
    }
  }
}