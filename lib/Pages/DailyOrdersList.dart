import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Constants/ApiConstants.dart';
import '../Models/Order.dart';
import '../db_helper.dart';
import '../services/OrdersService.dart';
import '../services/api_helper.dart';
import '../services/logoutService.dart';
import 'BookingsList.dart';
import 'DailyBookingsList.dart';
import 'Home.dart';
import '../theme/app_colors.dart';
import 'Login.dart';
import 'OrdersList.dart';

class DailyOrdersListPage extends StatefulWidget {
  final int userId;


  const DailyOrdersListPage({super.key, required this.userId});

  @override
  State<DailyOrdersListPage> createState() => _DailyOrdersListPageState();
}

class _DailyOrdersListPageState extends State<DailyOrdersListPage> {
  Map<String, dynamic>? utilisateur;
  late int userId;
  int _currentIndex = 0;
  final service = OrderService();
  List<Order> dailyOrders = [];
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
    load();
    scroll.addListener(() {
      if (scroll.position.pixels ==
          scroll.position.maxScrollExtent) {
        loadMore();
      }
    });

    _chargerUtilisateur();
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
      dailyOrders.clear();
    }

    final newData = await service.getDailyOrders(page, search, statutFilter);

    setState(() {
      if (reset) {
        dailyOrders = newData;
      } else {
        dailyOrders.addAll(newData); //
      }
    });
  }

  void loadMore() async {
    final newData = await service.getDailyOrders(page + 1, search, statutFilter);

    if (newData.isEmpty) return; //

    setState(() {
      page++;
      dailyOrders.addAll(newData);
    });
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
        title: Text("Commandes du jour",style: const TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,actions: [
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
                      icon: Icons.event_note_sharp,
                      text: "Reservations",
                      onTap: () {
                        Navigator.pushNamed(context, '/bookings');
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
                      icon: Icons.local_shipping,
                      text: "Livraisons",
                      onTap: () {
                        Navigator.pushNamed(context, '/shipping');
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
              "Liste des commandes du $today",
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

            //  FILTER 'Nouvelle', 'En préparation','Prête','Retirée','Annulée'
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, //  IMPORTANT
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: statutFilter,
                    hint: const Text("Statut"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "toutes", child: Text("Toutes")),
                      DropdownMenuItem(value: "Nouvelle", child: Text("Nouvelle")),
                      DropdownMenuItem(value: "En préparation", child: Text("En préparation")),
                      DropdownMenuItem(value: "Prête", child: Text("Prête")),
                      DropdownMenuItem(value: "Retirée", child: Text("Retirée")),
                      DropdownMenuItem(value: "Annulée", child: Text("Annulée")),
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
                itemCount: dailyOrders.length,
                itemBuilder: (context, index) {
                  final o = dailyOrders[index];
                  final dateCreation = DateTime.parse(o.dateCreation);
                  final dateRetrait = DateTime.parse(o.dateRetrait);

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text("Commande #${o.id}",style: TextStyle(color: AppColors.info),),
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
                          Text("Restaurant: ${o.restaurant.nom}"),
                          Text("Prix TTC: ${o.totalPrice} €"),
                          Text("Nombre d'éléments': ${o.items.length}"),
                          Text("Date de création: ${format.format(dateCreation)}"),
                          Text("Date de Commande: ${format.format(dateRetrait)}"),
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
                          IconButton(
                            icon: const Icon(Icons.message,color: AppColors.primary,),
                            onPressed: () => openMessagePopup(o),
                          ),

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

  void openStatusPopup(Order o) {
    showDialog(
      context: context,
      builder: (_) {
        String newStatus = o.statut;

        final statuses = [
          'Nouvelle',
          'En préparation',
          'Prête',
          'Retirée',
          'Annulée'
        ];

        return AlertDialog(
          title: const Text(
            "Changer le statut",
            style: TextStyle(color: AppColors.primary),
          ),

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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.light,
              ),
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

  void openMessagePopup(Order o) {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController messageCtrl = TextEditingController();

    String type = "email"; // default

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.6,
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(16),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🧾 TITLE
                    const Text(
                      "Envoyer un message",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 👤 CLIENT
                    Text(
                      "Client: ${o.client?.nom ?? ''} ${o.client?.prenom ?? ''}",
                    ),

                    const SizedBox(height: 15),

                    // 📧 TYPE
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: "Type",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "email", child: Text("Email")),
                        DropdownMenuItem(value: "sms", child: Text("SMS")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          type = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // 🏷 TITRE
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: "Titre",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 📝 MESSAGE
                    TextField(
                      controller: messageCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: "Message",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⚡ ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annuler"),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send),
                          label: const Text("Envoyer"),
                          onPressed: () async {

                            final title = titleCtrl.text.trim();
                            final message = messageCtrl.text.trim();

                            if (message.isEmpty) return;

                            await sendMessage(
                              commande_id:  o.id,
                              client_id:  o.clientId,
                              employe_id:  userId,
                              restaurant_id:  o.restaurantId,
                              societe_id:  o.societeId,
                              type:  type,
                              titre:  title,
                              texte:  message
                            );

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> sendMessage({
    required int commande_id,
    required int client_id,
    required int employe_id,
    required int restaurant_id,
    required int societe_id,
    required String type,
    required String titre,
    required String texte,
  }) async {
    final user = await DBHelper.getUser();
    final token = user?['access_token'];

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/ajouter_message"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "commande_id": commande_id,
        "type": type,
        "titre": titre,
        "texte": texte,
        "societe_id": societe_id,
        "restaurant_id": restaurant_id,
        "employe_id": employe_id,
        "client_id": client_id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur envoi message");
    }
  }


  void openDetailsPopup(Order o) {
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
                    "Commande #${o.id}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // 👤 CLIENT (SAFE)
                  Text(
                    "Client: ${o.client.nom} ${o.client.prenom }",
                  ),

                  const SizedBox(height: 8),

                  Text("Date: ${o.dateRetrait}"),
                  const SizedBox(height: 8),

                  Text("Prix TTC: ${o.totalPrice} €"),
                  const SizedBox(height: 8),

                  Text("Statut: ${o.statut}"),

                  const Divider(height: 25),

                  // 🍽 FORMULE
                  if (o.formule != null && o.formule!.isNotEmpty) ...[
                    const Text(
                      "Formule",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(o.formule!),
                    const SizedBox(height: 15),
                  ],

                  // 🧾 ITEMS SAFE
                  if ((o.items ?? []).isNotEmpty) ...[
                    const Text(
                      "Produits",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    ...o.items!.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // 🍽 PRODUIT
                              Text(
                                "• ${item['titre']} x${item['quantite']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text("Prix HT: ${item['prix_ht']} €"),

                              // 🔧 VARIATIONS SAFE
                              if (item['variations'] != null &&
                                  (item['variations'] as List).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("Variations:"),
                                      ...item['variations']
                                          .map<Widget>((v) {
                                        return Text(
                                          "- ${v['titre']} (+${v['prix_supplement']}€)",
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
      Uri.parse("${ApiConstants.baseUrl}/update_mobile_commande/$id"),
      headers: headers,
      body: jsonEncode({
        "statut": statut,
      }),
    );

    if (response.statusCode == 200) {
      // IMPORTANT : reload après update
      await service.reloadDatas();
    } else {
      throw Exception("Erreur update statut");
    }

    service.reloadDatas();
    load(reset: true);
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