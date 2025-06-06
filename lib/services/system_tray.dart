import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayService {
	final SystemTray _systemTray = SystemTray();
	final Menu _menuMain = Menu();

	bool _toggleMenu = true;

	final VoidCallback onShowWindow;
	final VoidCallback onHideWindow;
	final VoidCallback onMakeShot;
	final VoidCallback onOpenSettings;
  final VoidCallback onOpenAuth;

	SystemTrayService({
		required this.onShowWindow,
		required this.onHideWindow,
		required this.onMakeShot,
		required this.onOpenSettings,
    required this.onOpenAuth,
	});

	String _getTrayImagePath(String imageName) {
		return Platform.isWindows ? 'assets/$imageName.ico' : 'assets/$imageName.png';
	}

	String _getImagePath(String imageName) {
		return Platform.isWindows ? 'assets/$imageName.bmp' : 'assets/$imageName.png';
	}

	Future<void> initTray() async {
		await _systemTray.initSystemTray(iconPath: _getTrayImagePath('app_icon_white'));
		_systemTray.setTitle("");

		_systemTray.registerSystemTrayEventHandler((eventName) {
			if (eventName == kSystemTrayEventClick) {
					_systemTray.popUpContextMenu();
			} else if (eventName == kSystemTrayEventRightClick) {
					_toggleWindowVisibility();
			}
		});

		await _menuMain.buildFrom([
			MenuItemLabel(
				label: 'Сделать шот',
				//image: _getImagePath('darts_icon'),
				onClicked: (menuItem) => onMakeShot(),
			),
			MenuItemLabel(
				label: 'Настройки',
				onClicked: (menuItem) => onOpenSettings(),
			),
      MenuItemLabel(
				label: 'Авторизация',
				onClicked: (menuItem) => onOpenAuth(),
			),
			MenuSeparator(),
			MenuItemLabel(
				label: 'Закрыть',
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
