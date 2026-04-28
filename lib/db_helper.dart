import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Constants/ApiConstants.dart';


class DBHelper {
  static Database? _db;

  static Future<void> init() async {
    if (!kIsWeb) {
      _db ??= await _getDatabase();
    }
  }

  // ---------------- SQLITE ----------------
  static Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE utilisateur (
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
      },
    );
  }

  // ---------------- INSERT USER ----------------
  static Future<void> insertUser(Map<String, dynamic> user) async {
    final jsonString = jsonEncode(user);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('utilisateur', jsonString);
    } else {
      final db = _db ?? await _getDatabase();

      await db.insert(
        'utilisateur',
        {
          'id': user['id'],
          'data': jsonString, // 👈 tout le user ici
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ---------------- GET USER ----------------
  static Future<Map<String, dynamic>?> getUser() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('utilisateur');

      if (userString == null) return null;
      return jsonDecode(userString);
    } else {
      final db = _db ?? await _getDatabase();

      final result = await db.query('utilisateur', limit: 1);

      if (result.isEmpty) return null;

      final data = result.first['data'] as String;
      return jsonDecode(data);
    }
  }

  // ---------------- CLEAR ----------------
  static Future<void> clearUser() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('utilisateur');
    }
  }





}