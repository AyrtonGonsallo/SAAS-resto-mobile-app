import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Constants/ApiConstants.dart';
import '../Models/Order.dart';
import '../db_helper.dart';

class OrderService {
  final String baseUrl = ApiConstants.baseUrl;

  // CACHE LOCAL
  List<Order> _cache_daily = [];
  List<Order> _cache_all = [];
  DateTime? _lastFetch;

  // ⏱️ durée cache (ex: 5 min)
  final Duration cacheDuration = const Duration(minutes: 15);

  // -----------------------------
  // 🔥 API PRINCIPALE (FULL LOAD)
  // -----------------------------
  Future<void> getFreshOrders() async {
    final user = await DBHelper.getUser();
    final token = user?['access_token'];

    final response = await http.get(
      Uri.parse("$baseUrl/get_mobile_datas"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List dailyOrders = data['daily_orders'];
      final List allOrders = data['all_orders'];



      _cache_daily = dailyOrders.map((e) => Order.fromJson(e)).toList();

      _cache_all = allOrders.map((e) => Order.fromJson(e)).toList();
      _lastFetch = DateTime.now();

    } else {
      throw Exception("Erreur chargement Orders");
    }
  }


  Future<void> reloadDatas() async {
    await getFreshOrders();

    // reset cache time
    _lastFetch = DateTime.now();
  }

  // -----------------------------
  // ⚡ GET WITH CACHE + FILTER + PAGINATION
  // -----------------------------
  Future<List<Order>> getDailyOrders(
      int page,
      String search,
      String statut
      ) async {
    // 🔥 1. refresh API si cache vide ou expiré
    final shouldRefresh = _cache_daily.isEmpty ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > cacheDuration;

    if (shouldRefresh) {
      await getFreshOrders();
    }

    // 🔍 2. FILTRAGE LOCAL
    List<Order> filtered = _cache_daily;

    if (search.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.client.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.client.prenom.toLowerCase().contains(search.toLowerCase()) ||
            b.restaurant.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.statut.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    if (statut!="toutes") {
      filtered = filtered.where((b) {
        return
          b.statut.toLowerCase().contains(statut.toLowerCase());
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


  Future<List<Order>> getAllOrders(
      int page,
      String search,
      String statut
      ) async {
    // 🔥 1. refresh API si cache vide ou expiré
    final shouldRefresh = _cache_all.isEmpty ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > cacheDuration;

    if (shouldRefresh) {
      await getFreshOrders();
    }

    // 🔍 2. FILTRAGE LOCAL
    List<Order> filtered = _cache_all;

    if (search.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.client.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.client.prenom.toLowerCase().contains(search.toLowerCase()) ||
            b.restaurant.nom.toLowerCase().contains(search.toLowerCase()) ||
            b.statut.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    if (statut!="toutes") {
      filtered = filtered.where((b) {
        return
          b.statut.toLowerCase().contains(statut.toLowerCase());
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