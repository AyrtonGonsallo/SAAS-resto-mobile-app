class Role {
  final int id;
  final String titre;
  final String type;
  final int priorite;

  Role({required this.id, required this.titre, required this.type, required this.priorite});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      titre: json['titre'],
      type: json['type'],
      priorite: json['priorite'],
    );
  }
}
