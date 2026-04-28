import '../db_helper.dart';

Future<Map<String, String>> getHeaders() async {
  final user = await DBHelper.getUser();

  final token = user?['access_token'];

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}