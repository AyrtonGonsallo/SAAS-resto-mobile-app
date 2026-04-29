import 'Restaurant.dart';
import 'Table.dart';
import 'Utilisateur.dart';


class Booking {
  final int id;
  final String dateCreation;
  final String dateReservation;
  final int nombreDePersonnes;
  final int nbCouverts;
  final String statut;
  final String? notes;
  final String? demandesSpeciales;
  final Utilisateur client;
  final int restaurantId;
  final int tableId;
  final int clientId;
  final int societeId;
  final Restaurant restaurant;
  final Table table;


  Booking({
    required this.id,
    required this.dateCreation,
    required this.dateReservation,
    required this.nombreDePersonnes,
    required this.nbCouverts,
    required this.statut,
    this.notes,
    this.demandesSpeciales,
    required this.client,
    required this.restaurantId,
    required this.tableId,
    required this.clientId,
    required this.societeId,
    required this.restaurant,
    required this.table,

  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      dateCreation: json['date_creation'] ?? '',
      dateReservation: json['date_reservation'] ?? '',
      nombreDePersonnes: json['nombre_de_personnes'] ?? 0,
      nbCouverts: json['nb_couverts'] ?? 0,
      statut: json['statut'] ?? 'En attente',
      notes: json['notes'],
      demandesSpeciales: json['demandes_speciales'],
      client:Utilisateur.fromJson(json['client']),
      restaurantId: json['restaurant_id'],
      tableId: json['table_id'],
      clientId: json['client_id'],
      societeId: json['societe_id'],
      restaurant:  Restaurant.fromJson(json['Restaurant']),
      table:  Table.fromJson(json['table']),

    );
  }
}