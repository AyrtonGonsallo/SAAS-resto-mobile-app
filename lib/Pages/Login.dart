import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../Constants/ApiConstants.dart';
import '../db_helper.dart';
import '../theme/app_colors.dart';
import 'Home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = ApiConstants.baseUrl;
  }


  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> login() async {
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Données incomplètes",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/mobile_login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final user = data['user'];
          final access_token = data['accessToken'];
          final refresh_token = data['refreshToken'];
          user['access_token']=access_token;
          //print(user);
          Fluttertoast.showToast(
            msg: "Connexion réussie : ${user['nom']} ${user['prenom']} (${user['Role']['titre']})",
            backgroundColor:  AppColors.success,
            textColor: Colors.white,
          );
          await DBHelper.insertUser(user);
          Navigator.pushNamed(context, '/');

        } else {
          final data = jsonDecode(response.body);
          Fluttertoast.showToast(
            msg: "Erreur : ${data['message']}",
            backgroundColor:  AppColors.success,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Échec de la connexion: $e",
          backgroundColor: AppColors.failure,
          textColor: Colors.white,
        );
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo_app_500.png", width: 200),
              SizedBox(height: 40),
              _buildTextField(emailController, "Identifiant"),
              SizedBox(height: 20),
              _buildTextField(passwordController, "Mot de passe", obscureText: true),
              SizedBox(height: 10),

              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.black87),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        // Bordure par défaut
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),

        // Bordure quand enabled
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        // Bordure focus DORÉE (comme dans le popup)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.info, // Doré HomeRen
            width: 1.3,
          ),
        ),
      ),
    );
  }

}
