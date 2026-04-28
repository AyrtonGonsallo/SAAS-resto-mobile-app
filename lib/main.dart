import 'package:flutter/material.dart';
import 'package:saas_resto_mobile_app/Pages/MessagesList.dart';
import 'package:saas_resto_mobile_app/Pages/NotificationsList.dart';
import 'package:saas_resto_mobile_app/theme/app_colors.dart';

import 'AppState.dart';
import 'Pages/BookingsList.dart';
import 'Pages/DailyBookingsList.dart';
import 'Pages/DailyOrdersList.dart';
import 'Pages/Home.dart';
import 'Pages/Login.dart';
import 'Pages/OrdersList.dart';
import 'db_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final user = await DBHelper.getUser();


  AppState.isLoggedIn = user != null;
  AppState.userId = user != null ? user['id'] : 0;//DartError: TypeError: null: type 'Null' is not a subtype of type 'int'

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saas resto mobile manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
      ),

      initialRoute: AppState.isLoggedIn ? '/' : '/login',

      routes: {
        '/login': (context) => const LoginPage(title: 'Login'),

        '/': (context) =>
            HomePage(userId: AppState.userId),

        '/orders': (context) =>
            OrdersListPage(userId: AppState.userId),

        '/orders-today': (context) =>
            DailyOrdersListPage(userId: AppState.userId),

        '/bookings': (context) =>
            BookingsListPage(userId: AppState.userId),

        '/bookings-today': (context) =>
            DailyBookingsListPage(userId: AppState.userId),

        '/all-notifications': (context) =>
            NotificationsListPage(userId: AppState.userId),

        '/all-messages': (context) =>
            MessagesListPage(userId: AppState.userId),
      },
    );
  }
}


