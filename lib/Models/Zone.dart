class Zone {
  final int id;
  final String titre;
  final int? societeId;
  final int? restaurantId;

  Zone({
    required this.id,
    required this.titre,
    this.societeId,
    this.restaurantId,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      societeId: json['societe_id'],
      restaurantId: json['restaurant_id'],
    );
  }

}