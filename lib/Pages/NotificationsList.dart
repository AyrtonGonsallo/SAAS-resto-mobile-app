import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Constants/ApiConstants.dart';
import '../Models/Notification.dart';
import '../db_helper.dart';
import '../services/NotificationsService.dart';
import '../services/api_helper.dart';
import '../services/logoutService.dart';
import '../theme/app_colors.dart';
import 'Login.dart';

class NotificationsListPage extends StatefulWidget {
  final int userId;



  const NotificationsListPage({super.key, required this.userId});

  @override
  State<NotificationsListPage> createState() => _NotificationsListPageState();
}

class _NotificationsListPageState extends State<NotificationsListPage> {
  Map<String, dynamic>? utilisateur;
  late int userId;
  int _currentIndex = 0;
  final service = NotificationService();
  List<Notification> dailyNotifications = [];
  int page = 1;
  String search = "";
  String statutFilter="toutes";
  final TextEditingController searchCtrl = TextEditingController();
  final format = DateFormat('dd/MM/yyyy HH:mm');
  final ScrollController scroll = ScrollController();
  final today = DateFormat('dd/MM/yyyy').format(DateTime.now());


  final List<int> _navigationStack = [];

  final logoutService = LogoutService();

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
      dailyNotifications.clear();
    }

    final newData = await service.getAllNotifications(page, search, statutFilter);

    setState(() {
      if (reset) {
        dailyNotifications = newData;
      } else {
        dailyNotifications.addAll(newData); //
      }
    });
  }

  void loadMore() async {
    final newData = await service.getAllNotifications(page + 1, search, statutFilter);

    if (newData.isEmpty) return; //

    setState(() {
      page++;
      dailyNotifications.addAll(newData);
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications",style: const TextStyle(color: Colors.white),),
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
                      icon: Icons.shopping_bag,
                      text: "Commandes du jour",
                      onTap: () {
                        Navigator.pushNamed(context, '/orders-today');
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
              "Toutes les notifications",
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

            //  FILTER 'non lue', 'lue'
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, //  IMPORTANT
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: statutFilter,
                    hint: const Text("Statut"),
                    //'en_attente', 'envoyé', 'échoué'
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "toutes", child: Text("Toutes")),
                      DropdownMenuItem(value: "non lue", child: Text("non lue")),
                      DropdownMenuItem(value: "lue", child: Text("lue")),
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
                itemCount: dailyNotifications.length,
                itemBuilder: (context, index) {
                  final o = dailyNotifications[index];
                  var dateRappel;
                  if(o.dateRappel!=''){
                    dateRappel = DateTime.parse(o.dateRappel!);
                  }


                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text("notification #${o.id}",style: TextStyle(color: AppColors.info),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: o.statutLecture == "lue"
                                  ? AppColors.success
                                  : AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              o.statutLecture,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text("Restaurant: ${o.restaurant.nom}"),
                          Text("Type: ${o.type}"),
                          Text("Titre: ${o.titre}"),
                          Text(
                            dateRappel != null
                                ? format.format(dateRappel)
                                : '-',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //  Voir détails
                          IconButton(
                            icon: const Icon(Icons.visibility,color: AppColors.primary,),
                            onPressed: () async {
                              openDetailsPopup(o);
                              await updateStatut(o.id, 'lue');
                            },
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
  Future<void> updateStatut(int id, String statut_lecture) async {
    final headers = await getHeaders(); // avec token

    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/update_notification/$id"),
      headers: headers,
      body: jsonEncode({
        "statut_lecture": statut_lecture,
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



  void openDetailsPopup(Notification o) {
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

                  //  HEADER
                  Text(
                    "Notiffication #${o.id}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  //
                  Text(
                    "Type: ${o.type}",
                  ),

                  const SizedBox(height: 8),

                  Text("Date: ${o.dateRappel}"),
                  const SizedBox(height: 8),

                  Text("Titre: ${o.titre}"),
                  const SizedBox(height: 8),

                  Text("Statut: ${o.statutLecture}"),

                  const Divider(height: 25),

                  //
                  if (o.texte.isNotEmpty) ...[
                    const Text(
                      "Texte",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(o.texte),
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