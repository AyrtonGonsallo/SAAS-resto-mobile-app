import 'Zone.dart';
class Table {
  final int id;
  final String numero;
  final int nbPlaces;
  final String statut;
  final int? societeId;
  final int? zoneId;
  final int? restaurantId;
  final Zone zone;

  Table({
    required this.id,
    required this.numero,
    required this.nbPlaces,
    required this.statut,
    this.societeId,
    this.zoneId,
    this.restaurantId,
    required this.zone
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? '',
      nbPlaces: json['nb_places'] ?? 0,
      statut: json['statut'] ?? 'libre',
      societeId: json['societe_id'],
      zoneId: json['zone_id'],
      restaurantId: json['restaurant_id'],
      zone:  Zone.fromJson(json['ZoneTable']),
    );
  }


}