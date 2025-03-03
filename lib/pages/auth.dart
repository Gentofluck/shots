import 'package:flutter/material.dart';
import '../api/client.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPage extends StatefulWidget {
	final Function(String) changePage;
	final ShotsClient shotsClient;

	const AuthPage({required this.shotsClient, required this.changePage, Key? key}) : super(key: key);

	@override
	_AuthPageState createState() => _AuthPageState();
}

	class _AuthPageState extends State<AuthPage> {
		final TextEditingController _emailController = TextEditingController();
		final TextEditingController _passwordController = TextEditingController();
		bool _isLoading = false;

		@override
		Widget build(BuildContext context) {
			return Scaffold(
			body: Container(
				decoration: BoxDecoration(
					color: Color(0xFFF3EFEF)				
				),
				child: Center(
				child: Container(
					width: 300,
					padding: EdgeInsets.all(20),
					margin: EdgeInsets.symmetric(horizontal: 30),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(15),
						boxShadow: [
							BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
						],
					),
					child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						SvgPicture.asset(
							'assets/icon.svg',
							height: 80,
							width: 80, 
						),
						SizedBox(height: 20),
						TextField(
							controller: _emailController,
							decoration: InputDecoration(
								labelText: "Email",
								prefixIcon: Icon(Icons.email),
								border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
								filled: true,
								fillColor: Colors.white,
							),
							keyboardType: TextInputType.emailAddress,
						),
						SizedBox(height: 10),
						TextField(
						controller: _passwordController,
						obscureText: true,
						decoration: InputDecoration(
							labelText: "Пароль",
							prefixIcon: Icon(Icons.lock),
							border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
							filled: true,
							fillColor: Colors.white,
						),
						),
						SizedBox(height: 20),
						_isLoading
							? CircularProgressIndicator()
							: ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: Color(0xFF4AA37C),
									foregroundColor: Colors.white,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
									padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
								),
								onPressed: _handleLogin,
								child: Text("Войти", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
							),
					],
					),
				),
				),
			),
		);
	}

	Future<void> _handleLogin() async {
		setState(() {
			_isLoading = true;
		});

		String email = _emailController.text;
		String password = _passwordController.text;

		if (email.isEmpty || password.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите email и пароль')));
			setState(() {
				_isLoading = false;
			});
			return;
		}

		bool isAuthenticated = await widget.shotsClient.authenticate(email, password);

		if (isAuthenticated) widget.changePage('settingsPage');
		else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка авторизации')));

		setState(() {
			_isLoading = false;
		});
	}
}
