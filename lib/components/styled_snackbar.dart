import 'package:flutter/material.dart';

void showStyledSnackBar(BuildContext context, String message) {
	final messenger = ScaffoldMessenger.of(context);
  	messenger.removeCurrentSnackBar();
	
	ScaffoldMessenger.of(context).showSnackBar(
		SnackBar(
			backgroundColor: Color(0xFFF3EFEF),
			content: Text(
				message,
				style: TextStyle(
					fontFamily: 'IBMPlexMono',
					fontSize: 13,
					color: Color(0xFF3C3C3C),
				),
			),
			behavior: SnackBarBehavior.floating,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(8),
			),
			duration: Duration(seconds: 4),
			elevation: 4,
			margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
		),
	);
}
