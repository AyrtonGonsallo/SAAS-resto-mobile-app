class Restaurant {
  final int id;
  final String nom;
  final String telephone;
  final String ville;
  final String heure_debut;
  final String heure_fin;
  final String adresse;

  Restaurant({required this.id, required this.nom,required this.telephone,required this.ville,required this.heure_debut,required this.heure_fin,required this.adresse,});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      nom: json['nom'],
      telephone: json['telephone'],
      ville: json['ville'],
      heure_debut: json['heure_debut'],
      heure_fin: json['heure_fin'],
      adresse: json['adresse'],
    );
  }
}
