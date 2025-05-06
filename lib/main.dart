import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'dart:io';
import 'pages/home.dart';
import 'pages/screenshot.dart';
import 'pages/auth.dart';
import 'services/screenshot.dart';
import 'services/api/client.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'components/screenshot_editor.dart';

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

  hotKeyManager.unregisterAll();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  String? pageName;
  List<HotKey> _registeredHotKeyList = [];
  Uint8List? _screenshot;
  final ShotsClient shotsClient = ShotsClient();

  final GlobalKey<ScreenshotEditorState> editorKey = GlobalKey<ScreenshotEditorState>();
  
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
	await _loadSavedHotKeys();
	if (!(await shotsClient.checkToken())) {
	  setState(() {
		pageName = 'authPage';
	  });
	  showWindow();
	}
	else 
	{
	  if (_registeredHotKeyList.isNotEmpty)
	  {
		setState(() {
		  pageName = 'screenshotPage';
		});
		hideWindow();
	  }
	  else
	  {
		setState(() {
		  pageName = 'settingsPage';
		});
		showWindow();
	  }
	}
	//await hotKeyManager.unregisterAll();
  }

	Future<void> makeShot() async {
		Uint8List? screenshot = await ScreenshotService.captureScreen();
		if (screenshot != null && screenshot.isNotEmpty) {
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

  void _keyDownHandlerSend(HotKey hotKey) async {
	if (editorKey != null)
	  editorKey?.currentState?.uploadScreenshot();
  }

  Future<void> saveHotKey(String keyName, HotKey hotKey) async {
	final prefs = await SharedPreferences.getInstance();
	prefs.setString(keyName, jsonEncode(hotKey.toJson()));
  }


  Future<HotKey?> loadHotKey(String keyName) async {
	final prefs = await SharedPreferences.getInstance();
	final jsonStr = prefs.getString(keyName);
	if (jsonStr == null) return null;

	try {
	  return HotKey.fromJson(jsonDecode(jsonStr));
	} catch (e) {
	  return null;
	}
  }

  Future<void> _loadSavedHotKeys() async {
	HotKey? shotHotKey = await loadHotKey('shotHotKey');
	if (shotHotKey != null) {
	  await _handleHotKeyRegister(shotHotKey);
	}

	HotKey? sendHotKey = await loadHotKey('sendHotKey');
	if (sendHotKey != null) {
	  await _handleHotKeyRegisterSend(sendHotKey);
	}
  }

  Future<void> _handleHotKeyRegister(HotKey hotKey) async {
	await hotKeyManager.register(
	  hotKey,
	  keyDownHandler: _keyDownHandler,
	);
	setState(() {
	  _registeredHotKeyList = [...hotKeyManager.registeredHotKeyList];
	});
	await saveHotKey('shotHotKey', hotKey);
  }

  Future<void> _handleHotKeyRegisterSend(HotKey hotKey) async {
	await hotKeyManager.register(
	  hotKey,
	  keyDownHandler: _keyDownHandlerSend,
	);
	setState(() {
	  _registeredHotKeyList = [...hotKeyManager.registeredHotKeyList];
	});
	await saveHotKey('sendHotKey', hotKey);
  }

  void _changePage(String newPageName) {
	if (newPageName == 'screenshotPage') {
	  hideWindow();
	}
	else if (newPageName == 'settingsPage') {
	  showWindow();
	  hotKeyManager.unregisterAll();
	}
	else showWindow();
	

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
	  case 'settingsPage':
		return HomePage(
		  changePage: _changePage,
		  onScreenshotHotKeyRecorded: _handleHotKeyRegister,
		  onSendHotKeyRecorded: _handleHotKeyRegisterSend,
		  registeredHotKeyList: _registeredHotKeyList,
		  shotsClient: shotsClient,
		);
	  case 'screenshotPage':
	  default:
		return ScreenshotPage(
		  changePage: _changePage,
		  screenshot: _screenshot,
		  shotsClient: shotsClient,
		  makeShot: makeShot,
		  editorKey: editorKey,
		);
	}
  }
}