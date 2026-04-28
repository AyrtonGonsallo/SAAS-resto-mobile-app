
import 'Role.dart';
import 'Restaurant.dart';

class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String refresh_token;
  final String access_token;
  final String ? telephone;
  final int societe_id;
  final int role_id;
  final Role? role;
  final List<Restaurant>? restaurants; // 👈 AJOUT

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.refresh_token,
    required this.access_token,
    this.telephone,
    required this.role_id,
    required this.societe_id,
    this.role,
    this.restaurants,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      refresh_token: json['refresh_token'] ?? '',
      access_token: json['access_token'] ?? '',
      telephone: json['telephone']?? '',
      role_id: json['role_id'],
      societe_id: json['societe_id'] ?? 0,
      role: json['Role'] != null ? Role.fromJson(json['Role']) : null,
      restaurants: json['Restaurants'] != null
          ? (json['Restaurants'] as List)
          .map((e) => Restaurant.fromJson(e))
          .toList()
          : null,

    );
  }
}

