import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../Models/Message.dart';
import '../db_helper.dart';
import '../services/MessageService.dart';
import '../services/logoutService.dart';
import '../theme/app_colors.dart';
import 'Login.dart';

class MessagesListPage extends StatefulWidget {
  final int userId;



  const MessagesListPage({super.key, required this.userId});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  Map<String, dynamic>? utilisateur;
  late int userId;
  int _currentIndex = 0;
  final service = MessageService();
  List<Message> dailyMessages = [];
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
      dailyMessages.clear();
    }

    final newData = await service.getAllMessages(page, search, statutFilter);

    setState(() {
      if (reset) {
        dailyMessages = newData;
      } else {
        dailyMessages.addAll(newData); //
      }
    });
  }

  void loadMore() async {
    final newData = await service.getAllMessages(page + 1, search, statutFilter);

    if (newData.isEmpty) return; //

    setState(() {
      page++;
      dailyMessages.addAll(newData);
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
        title: Text("Messages",style: const TextStyle(color: Colors.white),),
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
                      icon: Icons.notifications,
                      text: "Notifications",
                      onTap: () {
                        Navigator.pushNamed(context, '/all-notifications');
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
              "Tous les messages",
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

            //  FILTER 'En attente', 'Confirmée','En cours','Annulée','Terminée','No-show'
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 🔥 IMPORTANT
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
                      DropdownMenuItem(value: "en_attente", child: Text("en attente")),
                      DropdownMenuItem(value: "envoyé", child: Text("envoyé")),
                      DropdownMenuItem(value: "échoué", child: Text("échoué")),
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
                itemCount: dailyMessages.length,
                itemBuilder: (context, index) {
                  final o = dailyMessages[index];
                  var dateEnvoi;
                  if((o.dateEnvoi) != ''){
                    dateEnvoi = DateTime.parse(o.dateEnvoi!);
                  }

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text("Message #${o.id}",style: TextStyle(color: AppColors.info),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: o.statutEnvoi == "en_attente"
                                  ? AppColors.success
                                  : AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              o.statutEnvoi,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text("Client: ${o.client.nom} ${o.client.prenom}"),
                          Text("Restaurant: ${o.restaurant.nom}"),
                          Text("Type: ${o.type}"),
                          Text("Titre: ${o.titre}"),
                          Text(
                            dateEnvoi != null
                                ? format.format(dateEnvoi)
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


  void openDetailsPopup(Message o) {
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
                    "Message #${o.id}",
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

                  Text("Date: ${o.dateEnvoi}"),
                  const SizedBox(height: 8),

                  Text("Titre: ${o.titre}"),
                  const SizedBox(height: 8),

                  Text("Statut: ${o.statutEnvoi}"),

                  const Divider(height: 25),

                  //
                  if (o.texte != null && o.texte!.isNotEmpty) ...[
                    const Text(
                      "Texte",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(o.texte!),
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