import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saas_resto_mobile_app/Pages/BookingsList.dart';
import 'package:saas_resto_mobile_app/Pages/DailyBookingsList.dart';
import 'package:saas_resto_mobile_app/Pages/DailyOrdersList.dart';
import 'package:saas_resto_mobile_app/Pages/OrdersList.dart';
import '../db_helper.dart';
import '../services/logoutService.dart';
import 'Login.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  final int userId;


  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? utilisateur;
  late int userId;
  int _currentIndex = 0;
  final List<Map<String, dynamic>> items = [
    {
      "title": "Commandes du jour",
      "image": "images/daily_commands.png",
      "route": "/orders-today"
    },
    {
      "title": "Toutes les commandes",
      "image": "images/all_commands.png",
      "route": "/orders"
    },
    {
      "title": "Réservations en cours",
      "image": "images/day_reservations.png",
      "route": "/bookings-today"
    },
    {
      "title": "Toutes les réservations",
      "image": "images/all_reservations.png",
      "route": "/bookings"
    },
  ];
  final List<int> _navigationStack = [];

  // ==============================
  // 🔥 NOUVELLES DONNÉES STATS
  // ==============================
  Map<String, dynamic>? statsGlobal;

  // Anciennes sections conservées
  List<Map<String, dynamic>> presenceParDojo = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _navigationStack.add(_currentIndex);

    _chargerUtilisateur();
  }

  Future<void> _chargerUtilisateur() async {
    final user = await DBHelper.getUser();
    setState(() {
      utilisateur = user;
    });
  }



  final logoutService = LogoutService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
        backgroundColor: AppColors.primary,
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
        child:
        Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.dark,
                            child: Icon(Icons.person, size: 30, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Bienvenue,", style: TextStyle(color: AppColors.dark)),
                                Text(
                                  "${utilisateur?['nom'] ?? ''} ${utilisateur?['prenom'] ?? ''} (${utilisateur?['Role']['titre'] ?? ''})",
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.primary),
                      onPressed: () async {
                        await logoutService.logout(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, item['route']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(item['image'], height: 250),
                            const SizedBox(height: 10),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color:AppColors.primary
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
        ),

      ),
      backgroundColor: Color(0xFFF5F7F9),
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