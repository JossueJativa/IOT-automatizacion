import 'package:flutter/material.dart';
import 'package:front_dev/common/button.dart';
import 'package:front_dev/common/input.dart';
import 'package:front_dev/common/label.dart';
import 'package:front_dev/common/link.dart';
import 'package:front_dev/functions/controller/authUser.dart';
import 'package:front_dev/functions/localAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool hasRefreshToken = false;

  @override
  void initState() {
    super.initState();
    _checkForRefreshToken();
  }

  Future<void> _checkForRefreshToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? refresh = pref.getString('refresh');
    setState(() {
      hasRefreshToken = refresh != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Login Page', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 20),
              const Label(text: 'Usuario: ', color: Colors.black, fontSize: 15),
              Input(
                placeholder: 'Ingrese su usuario',
                isPassword: false,
                controller: _usernameController,
                labelColor: Colors.black,
                icon: const Icon(Icons.person),
              ),
              const SizedBox(height: 20),
              const Label(
                  text: 'Contraseña: ', color: Colors.black, fontSize: 15),
              Input(
                placeholder: 'Ingrese su contraseña',
                isPassword: true,
                controller: _passwordController,
                labelColor: Colors.black,
                icon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Link(
                        text: 'Olvidaste tu contraseña?', url: 'forgot/'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Button(
                          text: 'Iniciar Sesión',
                          color: Colors.green,
                          textColor: Colors.white,
                          onPressed: () async {
                            final response = await login(
                              _usernameController.text,
                              _passwordController.text,
                            );

                            if (response['success'] != null) {
                              Navigator.pushNamed(context, 'home/');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['success']),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['error']),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        if (hasRefreshToken)
                          IconButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.blue),
                                iconSize: WidgetStateProperty.all(25),
                              ),
                              onPressed: () async {
                                await authenticateWithBiometrics(context);
                              },
                              icon: const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                              )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¿No tienes cuenta?'),
            Link(text: 'Regístrate', url: 'register/'),
          ],
        ),
      ),
    );
  }
}
