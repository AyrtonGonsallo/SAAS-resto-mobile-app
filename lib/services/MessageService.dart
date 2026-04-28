import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Constants/ApiConstants.dart';
import '../Models/Message.dart';
import '../db_helper.dart';

class MessageService {
  final String baseUrl = ApiConstants.baseUrl;

  // CACHE LOCAL
  List<Message> _cache_all = [];
  DateTime? _lastFetch;

  //  durée cache (ex: 5 min)
  final Duration cacheDuration = const Duration(minutes: 15);

  // -----------------------------
  //  API PRINCIPALE (FULL LOAD)
  // -----------------------------
  Future<void> getFreshMessages() async {
    final user = await DBHelper.getUser();
    final token = user?['access_token'];

    final response = await http.get(
      Uri.parse("$baseUrl/get_user_message"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

     
      final List allMessages = data;



    
      _cache_all = allMessages.map((e) => Message.fromJson(e)).toList();
      _lastFetch = DateTime.now();

    } else {
      throw Exception("Erreur chargement Messages");
    }
  }


  Future<void> reloadDatas() async {
    await getFreshMessages();

    // reset cache time
    _lastFetch = DateTime.now();
  }




  Future<List<Message>> getAllMessages(
      int page,
      String search,
      String statut
      ) async {
    // 🔥 1. refresh API si cache vide ou expiré
    final shouldRefresh = _cache_all.isEmpty ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > cacheDuration;

    if (shouldRefresh) {
      await getFreshMessages();
    }

    // 🔍 2. FILTRAGE LOCAL
    List<Message> filtered = _cache_all;

    if (search.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.client.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.client.prenom.toLowerCase().contains(search.toLowerCase()) ||
            b.restaurant.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.statutEnvoi.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    if (statut!="toutes") {
      filtered = filtered.where((b) {
        return
          b.statutEnvoi.toLowerCase().contains(statut.toLowerCase());
      }).toList();
    }


    // 📄 3. PAGINATION LOCALE
    const int limit = 10;
    final start = (page - 1) * limit;
    final end = start + limit;

    if (start >= filtered.length) return [];

    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }
}