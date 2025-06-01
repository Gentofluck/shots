import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShotsClient {
	final String _baseUrl = "https://shots.m18.ru/";
	String? token;
	String? email;
  String? password;


	bool get hasToken => token?.isNotEmpty ?? false;

	Future<void> init() async {
		final prefs = await SharedPreferences.getInstance();
		token = prefs.getString('token');
		email = prefs.getString('email');
    password = prefs.getString('password');
	}

	Future<bool> authenticate(String email, String password) async {
		final response = await _postRequest(
			"login/",
			{
				"mail": email,
				"pass": password,
			},
		);

		if (response.isEmpty) return false;

		final prefs = await SharedPreferences.getInstance();
		prefs.setString('token', response);
		prefs.setString('email', email);
    prefs.setString('password', password);

		token = response;
		this.email = email;
    this.password = password;

		return true;
	}

	void logout() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.remove('token');
		token = null;
	}

	Future<bool> checkToken() async {
		if (token == null && (email == null || password == null)) return false;

		final response = await _getRequest("ping/$token/");
		
		if (response == "OK$token") return true;
		else {
			return await authenticate(email!, password!);
		}
	}

	Future<String> uploadImage(Uint8List bytes) async {
		final uri = Uri.parse("$_baseUrl/upload/");
		final request = http.MultipartRequest('POST', uri)
		..fields['token'] = token ?? ""
		..files.add(http.MultipartFile.fromBytes('userfile', bytes, filename: 'image.png'));

		final response = await request.send();

		final responseBody = await http.Response.fromStream(response);
		return responseBody.body;
	}

	Future<String> _postRequest(String uri, Map<String, String> queryParams) async {
		final uriParsed = Uri.parse("$_baseUrl$uri");
		queryParams['app'] = '1';

		final response = await http.post(
			uriParsed,
			headers: {'Content-Type': 'application/x-www-form-urlencoded'},
			body: queryParams,
		);

		if (response.statusCode != 200 || response.body.isEmpty || response.body == 'ERROR') {
			return "";
		}

		return response.body;
	}

	Future<String> _getRequest(String uri) async {
		final uriParsed = Uri.parse("$_baseUrl$uri");
		final response = await http.get(uriParsed);

		if (response.statusCode != 200 || response.body.isEmpty) {
			return "";
		}

		return response.body;
	}
}
