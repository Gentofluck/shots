import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_size/window_size.dart';
//import 'package:tray_manager/tray_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'dart:io';
import 'pages/home.dart';
import 'pages/screenshot.dart';
import 'pages/auth.dart';
import 'services/screenshot.dart';
import 'api/client.dart';
import 'package:window_manager/window_manager.dart';

void main() async{
	WidgetsFlutterBinding.ensureInitialized();

	await hotKeyManager.unregisterAll();
	await windowManager.ensureInitialized();

	if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
		setWindowTitle('Shots');
  	}

	runApp(MyApp());
}

class MyApp extends StatefulWidget {

	const MyApp({super.key});

	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	String pageName = 'settingsPage';
  	List<HotKey> _registeredHotKeyList = [];
	Uint8List? _screenshot;
	final ShotsClient shotsClient = ShotsClient(); 

	@override
	void initState() {
		super.initState();
		_initialize();
	}

	Future<void> hideWindow() async {
		await windowManager.hide();
		await windowManager.setSkipTaskbar(true);
	}

	Future<void> showWindow() async {
		await windowManager.show();
		await windowManager.setSkipTaskbar(false);
	}


	Future<void> _initialize() async {
		await shotsClient.init();
		if (!(await shotsClient.checkToken())) {
			setState(() {
				pageName = 'authPage';
			});
		}
	}

	Future<void> makeShot () async {
		Uint8List? screenshot = await ScreenshotService.captureScreen();
		if (screenshot != null) {
			showWindow();
			setState(() {
				_screenshot = screenshot;
			});
		}
	}

	void _keyDownHandler(HotKey hotKey) async {
		print("handler" + hotKey.toString());
		makeShot();
	}

	Future<void> _handleHotKeyRegister(HotKey hotKey) async {
		print("register" + hotKey.toString());
		await hotKeyManager.register(
			hotKey,
			keyDownHandler: _keyDownHandler,
		);
		setState(() {
			_registeredHotKeyList = hotKeyManager.registeredHotKeyList;
		});
	}

	void _changePage(String newPageName) {
		if (pageName != newPageName && newPageName == 'screenshotPage') {
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
			home: 
			pageName == 'settingsPage' 
			? 
			HomePage
			(
				changePage: _changePage, 
				onHotKeyRecorded: (newHotKey) => _handleHotKeyRegister(newHotKey),
				shotsClient: shotsClient
			) 
			:
			( 
			pageName == 'authPage' 
			?
			AuthPage
			(
				changePage: _changePage, 
				shotsClient: shotsClient
			) 
			: ScreenshotPage
			(
				screenshot: _screenshot,
				shotsClient: shotsClient,
				makeShot: makeShot,
			))
		);
	}
}



