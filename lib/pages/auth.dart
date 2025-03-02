import 'package:flutter/material.dart';
import '../api/client.dart'; 

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
			appBar: AppBar(title: Text("Авторизация")),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						TextField(
							controller: _emailController,
							decoration: InputDecoration(labelText: "Email"),
							keyboardType: TextInputType.emailAddress,
						),
						TextField(
							controller: _passwordController,
							obscureText: true,
							decoration: InputDecoration(labelText: "Пароль"),
						),
						SizedBox(height: 20),
						_isLoading
							? CircularProgressIndicator()
							: ElevatedButton(
								onPressed: _handleLogin,
								child: Text("Войти"),
						),
					],
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
