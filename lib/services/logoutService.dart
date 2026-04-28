
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../AppState.dart';
import '../db_helper.dart';
class LogoutService {
  Future<void> logout(BuildContext context) async {
    Fluttertoast.showToast(
      msg: "Déconnexion",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    await DBHelper.clearUser();

    AppState.isLoggedIn = false;
    AppState.userId = 0;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}