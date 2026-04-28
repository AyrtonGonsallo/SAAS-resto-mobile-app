import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../AppState.dart';
import '../Constants/ApiConstants.dart';
import '../Models/Livraison.dart';
import '../db_helper.dart';
import '../services/LivraisonsService.dart';
import '../services/LivraisonsService.dart';
import '../services/api_helper.dart';
import '../services/logoutService.dart';
import 'DailyOrdersList.dart';
import 'Home.dart';
import 'Login.dart';
import '../theme/app_colors.dart';
import 'OrdersList.dart';

class LivraisonsListPage extends StatefulWidget {
  final int userId;



  const LivraisonsListPage({super.key, required this.userId});

  @override
  State<LivraisonsListPage> createState() => _LivraisonsListPageState();
}

class _LivraisonsListPageState extends State<LivraisonsListPage> {
  Map<String, dynamic>? utilisateur;
  late int userId;
  int _currentIndex = 0;
  final service = LivraisonService();
  List<Livraison> dailyLivraisons = [];
  int page = 1;
  String search = "";
  String statutFilter="toutes";
  final TextEditingController searchCtrl = TextEditingController();
  final format = DateFormat('dd/MM/yyyy HH:mm');
  final ScrollController scroll = ScrollController();
  final today = DateFormat('dd/MM/yyyy').format(DateTime.now());


  final List<int> _navigationStack = [];



  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _navigationStack.add(_currentIndex);

    _chargerUtilisateur();
    load();
    scroll.addListener(() {
      if (scroll.position.pixels ==
          scroll.position.maxScrollExtent) {
        loadMore();
      }
    });

  }

  Future<void> _chargerUtilisateur() async {
    final user = await DBHelper.getUser();
    setState(() {
      utilisateur = user;
    });
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      page = 1;
      dailyLivraisons.clear();
    }

    final newData = await service.getAllLivraisons(page, search,statutFilter);

    setState(() {
      dailyLivraisons = newData;
    });
  }

  void loadMore() {
    page++;
    load();
  }

  void onSearchChanged(String value) {
    search = value;
    load(reset: true);
  }

  void onStatusChanged(String? value) {
    statutFilter = value!;
    load(reset: true);
  }

  final logoutService = LogoutService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Livraisons",style: const TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
        actions: [
          Row(
            children: [

              //  IMAGE
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary, size: 18),
              ),

              const SizedBox(width: 8),

              //  TEXTE
              Text(
                "${utilisateur?['nom'] ?? ''} ${utilisateur?['prenom'] ?? ''} (${utilisateur?['Role']['titre'] ?? ''})",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(width: 10),

              //  LOGOUT
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.light),
                onPressed: () async {
                  await logoutService.logout(context);
                },
              ),

              const SizedBox(width: 10),
            ],
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.light,

                ),
                child: Center(
                  child: Image.asset(
                    "images/logo_app_150.png",
                    height: 60,
                  ),
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.home,
                      text: "Accueil",
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.event_rounded,
                      text: "Reservations du jour",
                      onTap: () {
                        Navigator.pushNamed(context, '/bookings-today');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_basket,
                      text: "Commandes",
                      onTap: () {
                        Navigator.pushNamed(context, '/orders');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_bag,
                      text: "Commandes du jour",
                      onTap: () {
                        Navigator.pushNamed(context, '/orders-today');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications,
                      text: "Notifications",
                      onTap: () {
                        Navigator.pushNamed(context, '/all-notifications');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.message_sharp,
                      text: "Messages",
                      onTap: () {
                        Navigator.pushNamed(context, '/all-messages');
                      },
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            //  TITLE
            Text(
              "Toutes les livraisons",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 🔍 SEARCH
            TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Rechercher...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            //  FILTER 'En attente','En cours','Annulée','Terminée'
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 🔥 IMPORTANT
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: statutFilter,
                    hint: const Text("Statut"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "toutes", child: Text("Toutes")),
                      DropdownMenuItem(value: "En attente", child: Text("En attente")),
                      DropdownMenuItem(value: "En cours", child: Text("En cours")),
                      DropdownMenuItem(value: "Annulée", child: Text("Annulée")),
                      DropdownMenuItem(value: "Terminée", child: Text("Terminée")),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            //  LISTE
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: dailyLivraisons.length,
                itemBuilder: (context, index) {
                  final o = dailyLivraisons[index];
                  final dateLivraison = DateTime.parse(o.dateLivraison);

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text("Livraison #${o.id}",style: TextStyle(color: AppColors.info),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: o.statut == "Confirmée"
                                  ? AppColors.success
                                  : AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              o.statut,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text("Client: ${o.client.nom} ${o.client.prenom}"),
                          Text("Livreur: ${o.livreur.nom} ${o.livreur.prenom}"),
                          Text("Restaurant: ${o.restaurant.nom}"),
                          Text("Adresse: ${o.adresseLivraison}"),
                          Text("Date de livraison: ${format.format(dateLivraison)}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //  Modifier statut
                          IconButton(
                            icon: const Icon(Icons.edit,color: AppColors.primary,),
                            onPressed: () => openStatusPopup(o),
                          ),
                          //  Envoyer un message



                          //  Voir détails
                          IconButton(
                            icon: const Icon(Icons.visibility,color: AppColors.primary,),
                            onPressed: () => openDetailsPopup(o),
                          ),
                        ],
                      ),

                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF5F7F9),
    );
  }



  void openStatusPopup(Livraison o) {
    showDialog(
      context: context,
      builder: (_) {
        String newStatus = o.statut;
        final statuses = ['En attente','En cours','Annulée','Terminée'];

        return AlertDialog(
          title: const Text("Changer le statut",style: TextStyle(color: AppColors.primary),),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: newStatus,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Statut",
                  border: OutlineInputBorder(),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    newStatus = value!;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primary),foregroundColor: WidgetStateProperty.all(AppColors.light)),
              onPressed: () async {
                await updateStatut(o.id, newStatus);
                Navigator.pop(context);
                load(reset: true);
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  void openDetailsPopup(Livraison o) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            constraints: const BoxConstraints(maxWidth: 850),
            padding: const EdgeInsets.all(18),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🧾 HEADER
                  Text(
                    "Livraison #${o.id}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // 👤 CLIENT
                  Text(
                    "Client: ${o.client.nom } ${o.client.prenom}",
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  Text("Date: ${o.dateLivraison}"),
                  const SizedBox(height: 8),

                  Text("Adresse: ${o.adresseLivraison}"),
                  const SizedBox(height: 8),

                  Text("Statut: ${o.statut}"),

                  const Divider(height: 25),

                  // 📝 NOTES
                  if (o.notesLivreur != null && o.notesLivreur!.isNotEmpty) ...[
                    const Text(
                      "Notes livreur",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(o.notesLivreur!),
                    const SizedBox(height: 15),
                  ],

                  const SizedBox(height: 20),

                  // ⚡ ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fermer"),
                      ),

                      const SizedBox(width: 10),


                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> updateStatut(int id, String statut) async {
    final headers = await getHeaders(); // avec token

    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/update_livraison_statut/$id"),
      headers: headers,
      body: jsonEncode({
        "statut": statut,
      }),
    );

    if (response.statusCode == 200) {
      //  IMPORTANT : reload après update
      await service.reloadDatas();
    } else {
      throw Exception("Erreur update statut");
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: Colors.black12,
        highlightColor: Colors.black12,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.black87),
            title: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ),
    );
  }

}