import 'package:saas_resto_mobile_app/Models/Utilisateur.dart';

import 'Restaurant.dart';

class OrderSimple {
  final int id;
  final String dateCreation;
  final String dateRetrait;
  final String statut;
  final String? formule;
  final double totalPrice;
  final List<dynamic> items;
  final int restaurantId;
  final int societeId;
  final int clientId;

  OrderSimple({
    required this.id,
    required this.dateCreation,
    required this.dateRetrait,
    required this.statut,
    this.formule,
    required this.totalPrice,
    required this.items,
    required this.restaurantId,
    required this.societeId,
    required this.clientId,
  });

  factory OrderSimple.fromJson(Map<String, dynamic> json) {
    return OrderSimple(
      id: json['id'],
      dateCreation: json['date_creation'] ?? '',
      dateRetrait: json['date_retrait'] ?? '',
      statut: json['statut'] ?? 'Nouvelle',
      formule: json['formule'],
      totalPrice: parseDouble(json['totalPrice']),
      items: json['items'] ?? [],
      restaurantId: json['restaurant_id'],
      clientId: json['client_id'],
      societeId: json['societe_id'],
    );
  }


}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}