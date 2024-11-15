import 'package:flutter/material.dart';
import 'package:front_dev/functions/controller/authUser.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<void> authenticateWithBiometrics(BuildContext context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? refresh = pref.getString('refresh');

  if (refresh != null) {
    verifyAndRefreshToken(refresh);

    bool canCheckBiometrics = await auth.canCheckBiometrics;

    if (canCheckBiometrics) {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor, autentíquese para acceder',
      );

      if (didAuthenticate) {
        Navigator.pushNamed(context, 'home/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo autenticar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
