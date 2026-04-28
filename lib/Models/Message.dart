import 'package:saas_resto_mobile_app/Models/Utilisateur.dart';

import 'Restaurant.dart';

class Message {
  final int id;
  final String type; // sms | email
  final String titre;
  final String? texte;
  final String? dateEnvoi;
  final String statutEnvoi;

  final int? reservationId;
  final int? commandeId;
  final int? societeId;
  final int? restaurantId;
  final int? employeId;
  final int? clientId;
  final Utilisateur client;
  final Utilisateur employe;
  final Restaurant restaurant;


  Message({
    required this.id,
    required this.type,
    required this.titre,
    this.texte,
    this.dateEnvoi,
    required this.statutEnvoi,
    this.reservationId,
    this.commandeId,
    this.societeId,
    this.restaurantId,
    this.employeId,
    this.clientId,
    required this.client,
    required this.employe,
    required this.restaurant
  });

  // -----------------------------
  // 🔄 FROM JSON
  // -----------------------------
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'email',
      titre: json['titre'] ?? '',
      texte: json['texte'],

      dateEnvoi: json['date_envoi'] ?? '',

      statutEnvoi: json['statut_envoi'] ?? 'en_attente',

      reservationId: json['reservation_id'],
      commandeId: json['commande_id'],
      societeId: json['societe_id'],
      restaurantId: json['restaurant_id'],
      employeId: json['employe_id'],
      clientId: json['client_id'],
      client: Utilisateur.fromJson(json['client']),
      employe: Utilisateur.fromJson(json['employe']),
      restaurant: Restaurant.fromJson(json['Restaurant']),
    );
  }

}