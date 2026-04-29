import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Constants/ApiConstants.dart';
import '../Models/Booking.dart';
import '../db_helper.dart';

class BookingService {
  final String baseUrl = ApiConstants.baseUrl;

  // CACHE LOCAL
  List<Booking> _cache_daily = [];
  List<Booking> _cache_all = [];
  DateTime? _lastFetch;



  // ⏱️ durée cache (ex: 5 min)
  final Duration cacheDuration = const Duration(minutes: 15);

  // -----------------------------
  // 🔥 API PRINCIPALE (FULL LOAD)
  // -----------------------------
  Future<void> getFreshBookings() async {
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

      final List dailyBookings = data['daily_bookings'];
      final List allBookings = data['all_bookings'];

      _cache_daily = dailyBookings.map((e) => Booking.fromJson(e)).toList();

      _cache_all = allBookings.map((e) => Booking.fromJson(e)).toList();
      _lastFetch = DateTime.now();

    } else {
      throw Exception("Erreur chargement Bookings");
    }
  }

  Future<void> reloadDatas() async {
    await getFreshBookings();

    // reset cache time
    _lastFetch = DateTime.now();
  }

  // -----------------------------
  // ⚡ GET WITH CACHE + FILTER + PAGINATION
  // -----------------------------
  Future<List<Booking>> getDailyBookings(
      int page,
      String search,
      String statut
      ) async {
    // 🔥 1. refresh API si cache vide ou expiré
    final shouldRefresh = _cache_daily.isEmpty ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > cacheDuration;

    if (shouldRefresh) {
      await getFreshBookings();
    }

    // 🔍 2. FILTRAGE LOCAL
    List<Booking> filtered = _cache_daily;

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


  Future<List<Booking>> getAllBookings(
      int page,
      String search,
      String statut
      ) async {
    //  1. refresh API si cache vide ou expiré
    final shouldRefresh = _cache_all.isEmpty ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > cacheDuration;

    if (shouldRefresh) {
      await getFreshBookings();
    }

    //  2. FILTRAGE LOCAL
    List<Booking> filtered = _cache_all;

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