import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api/client.dart';
import '../components/styled_snackbar.dart';

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
		final style = const TextStyle(
			fontFamily: 'IBMPlexMono',
			fontWeight: FontWeight.w400,
			fontSize: 12,
			color: Color(0xFF3C3C3C),
		);

		return Scaffold(
			body: Container(
				decoration: BoxDecoration(
					color: Color(0xFFF3EFEF),
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
								RichText(
									text: TextSpan(
										style: style,
										children: [
										const TextSpan(text: "Войдите, чтобы продолжить. \nЕсли у вас нет аккаунта, зарегистрируйтесь на "),
										TextSpan(
											text: 'shots.m18.ru',
											style: style.copyWith(
												color: Color(0xFF425AD0),
												decoration: TextDecoration.underline,
											),
											recognizer: TapGestureRecognizer()
											..onTap = () async {
												final url = Uri.parse('https://shots.m18.ru');
												if (await canLaunchUrl(url)) {
													await launchUrl(url, mode: LaunchMode.externalApplication);
												} else {
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('Не удалось открыть ссылку')),
													);
												}
											},
										),
										],
									),
								),
								SizedBox(height: 20),
								Container(
									height: 40,
									child: TextField(
										controller: _emailController,
										decoration: InputDecoration(
											labelText: "Email",
											labelStyle: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14),
											prefixIcon: Icon(Icons.email, color: Color(0xFF3C3C3C)),
											enabledBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(4),
												borderSide: BorderSide(color: Color(0xFF3C3C3C)),
											),
											focusedBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(4),
												borderSide: BorderSide(color: Color(0xFF425AD0)),
											),
											filled: true,
											fillColor: Colors.white,
											contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12), 
										),
										keyboardType: TextInputType.emailAddress,
										style: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14, color: Color(0xFF3C3C3C)), 
									),
								),
								SizedBox(height: 10),
								Container(
									height: 40,
									child: TextField(
										controller: _passwordController,
										obscureText: true,
										decoration: InputDecoration(
											labelText: "Пароль",
											labelStyle: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14),
											prefixIcon: Icon(Icons.lock),
											enabledBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(4),
												borderSide: BorderSide(color: Color(0xFF3C3C3C)),
											),
											focusedBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(4),
												borderSide: BorderSide(color: Color(0xFF425AD0)),
											),
											filled: true,
											fillColor: Colors.white,
											contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
										),
										style: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14, color: Color(0xFF3C3C3C)), 
									),
								),
								SizedBox(height: 20),
								_isLoading
								? SizedBox(
									width: 32,
									height: 32,
									child: CircularProgressIndicator(
										strokeWidth: 2.5,
										color: Color(0xFF425AD0),
									),
								)
								: ElevatedButton(
									style: ElevatedButton.styleFrom(
										backgroundColor: Color(0xFF425AD0),
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(4),
										),
										padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
									),
									onPressed: _handleLogin,
									child: Text(
										"Войти",
										style: TextStyle(
											fontFamily: 'IBMPlexMono',
											fontWeight: FontWeight.w500,
											fontSize: 14,
										),
									),
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
			showStyledSnackBar(context, 'Пожалуйста, заполните все поля');
			setState(() {
				_isLoading = false;
			});
			return;
		}

		bool isAuthenticated = await widget.shotsClient.authenticate(email, password);

		if (isAuthenticated) widget.changePage('settingsPage');
		else showStyledSnackBar(context, 'Неверный email или пароль');

		setState(() {
			_isLoading = false;
		});
	}
}
