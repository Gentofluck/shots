import 'package:flutter/material.dart';
import '../services/api/client.dart';

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
                SizedBox(height: 20),
                Container(
                  height: 40,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14),
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12), 
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14), 
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
                    ),
                    style: TextStyle(fontFamily: 'IBMPlexMono', fontSize: 14), 
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
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
