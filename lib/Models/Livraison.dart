
import 'OrderSimple.dart';
import 'Restaurant.dart';
import 'Utilisateur.dart';

class Livraison {
  final int id;
  final String dateLivraison;
  final String? notesLivreur;
  final String adresseLivraison;
  final String? codePostal;
  final String? ville;
  final double fraisLivraison;
  final int? commandeId;
  final int? livreurId;
  final int? clientId;
  final String statut;
  final int? societeId;
  final int? restaurantId;
  final Utilisateur client;
  final Utilisateur livreur;
  final Restaurant restaurant;
  final OrderSimple commande;

  Livraison({
    required this.id,
    required this.dateLivraison,
    this.notesLivreur,
    required this.adresseLivraison,
    this.codePostal,
    this.ville,
    required this.fraisLivraison,
    this.commandeId,
    this.livreurId,
    this.clientId,
    required this.statut,
    this.societeId,
    this.restaurantId,
    required this.client,
    required this.livreur,
    required this.restaurant,
    required this.commande
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] ?? 0,

      dateLivraison: json['date_livraison'] ,

      notesLivreur: json['notes_livreur'],

      adresseLivraison: json['adresse_livraison'] ?? '',

      codePostal: json['code_postal'],

      ville: json['ville'],

      fraisLivraison: parseDouble(json['frais_livraison']),

      commandeId: json['commande_id'],
      livreurId: json['livreur_id'],
      clientId: json['client_id'],

      statut: json['statut'] ?? 'En attente',

      societeId: json['societe_id'],
      restaurantId: json['restaurant_id'],
      client: Utilisateur.fromJson(json['client']),
      livreur: Utilisateur.fromJson(json['client']),
      restaurant:  Restaurant.fromJson(json['Restaurant']),
      commande:  OrderSimple.fromJson(json['commande']),
    );
  }

}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}