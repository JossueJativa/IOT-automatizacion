import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:front_dev/pages/Device.dart';
import 'package:front_dev/pages/homePage.dart';
import 'package:front_dev/pages/loginPage.dart';
import 'package:front_dev/pages/registerPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        'register/': (context) => const RegisterPage(),
        'home/': (context) => const HomePage(),
        'device/': (context) => Device(
              deviceId: ModalRoute.of(context)!.settings.arguments as int,
            ),
      },
    );
  }
}
