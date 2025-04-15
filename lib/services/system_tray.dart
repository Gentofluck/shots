import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayService {
	final SystemTray _systemTray = SystemTray();
	final Menu _menuMain = Menu();
	final Menu _menuSimple = Menu();

	bool _toggleMenu = true;

	final VoidCallback onShowWindow;
	final VoidCallback onHideWindow;

	SystemTrayService({
		required this.onShowWindow,
		required this.onHideWindow,
	});

	String _getTrayImagePath(String imageName) {
		return Platform.isWindows ? 'assets/$imageName.ico' : 'assets/$imageName.png';
	}

	String _getImagePath(String imageName) {
		return Platform.isWindows ? 'assets/$imageName.bmp' : 'assets/$imageName.png';
	}

	Future<void> initTray() async {
		await _systemTray.initSystemTray(iconPath: _getTrayImagePath('app_icon'));
		_systemTray.setTitle("shoots");
		_systemTray.setToolTip("How to use system tray with Flutter");

		_systemTray.registerSystemTrayEventHandler((eventName) {
			if (eventName == kSystemTrayEventClick) {
				if (Platform.isWindows) {
					_toggleWindowVisibility();
				} else {
					_systemTray.popUpContextMenu();
				}
			} else if (eventName == kSystemTrayEventRightClick) {
				if (Platform.isWindows) {
					_systemTray.popUpContextMenu();
				} else {
					_toggleWindowVisibility();
				}
			}
		});

		await _menuMain.buildFrom([
			MenuItemLabel(
				label: 'Change Context Menu',
				image: _getImagePath('darts_icon'),
				onClicked: (menuItem) {
					_toggleMenu = !_toggleMenu;
					_systemTray.setContextMenu(_toggleMenu ? _menuMain : _menuSimple);
				},
			),
			MenuSeparator(),
			MenuItemLabel(
				label: 'Show Window',
				image: _getImagePath('darts_icon'),
				onClicked: (menuItem) => onShowWindow(),
			),
			MenuItemLabel(
				label: 'Hide Window',
				image: _getImagePath('darts_icon'),
				onClicked: (menuItem) => onHideWindow(),
			),
			MenuItemLabel(
				label: 'Exit',
				onClicked: (menuItem) async {
					await windowManager.destroy();
					exit(0);
				},
			),
		]);

		await _menuSimple.buildFrom([
			MenuItemLabel(
				label: 'Simple Menu',
				image: _getImagePath('app_icon'),
				onClicked: (menuItem) {
					_toggleMenu = !_toggleMenu;
					_systemTray.setContextMenu(_toggleMenu ? _menuMain : _menuSimple);
				},
			),
			MenuItemLabel(
				label: 'Exit',
				onClicked: (menuItem) async {
					await windowManager.destroy();
					exit(0);
				},
			),
		]);

		_systemTray.setContextMenu(_menuMain);
	}

	Future<void> _toggleWindowVisibility() async {
		bool isVisible = await windowManager.isVisible();
		if (isVisible) {
			onHideWindow();
		} else {
			onShowWindow();
		}
	}
}
