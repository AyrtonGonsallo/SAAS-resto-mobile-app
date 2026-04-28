import 'Restaurant.dart';

class Notification {
  final int id;

  final String type; // message de confirmation | alerte | rappel | info
  final String titre;
  final String texte;

  final String? dateRappel;

  final String canal; // mails | sms | site
  final String statutLecture; // non lue | lue

  final int societeId;
  final int restaurantId;
  final int? utilisateurId;
  final Restaurant restaurant;

  Notification({
    required this.id,
    required this.type,
    required this.titre,
    required this.texte,
    this.dateRappel,
    required this.canal,
    required this.statutLecture,
    required this.societeId,
    required this.restaurantId,
    this.utilisateurId,
    required this.restaurant
  });

  // -----------------------------
  // 🔄 FROM JSON
  // -----------------------------
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'message de confirmation',
      titre: json['titre'] ?? '',
      texte: json['texte'] ?? '',

      dateRappel: json['date_rappel'] ?? '',

      canal: json['canal'] ?? 'site',
      statutLecture: json['statut_lecture'] ?? 'non lue',

      societeId: json['societe_id'],
      restaurantId: json['restaurant_id'],
      utilisateurId: json['utilisateur_id'],
      restaurant: Restaurant.fromJson(json['Restaurant']),
    );
  }


}