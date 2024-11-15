import 'package:flutter/material.dart';
import 'package:front_dev/common/button.dart';
import 'package:front_dev/common/input.dart';
import 'package:front_dev/common/label.dart';
import 'package:front_dev/common/link.dart';
import 'package:front_dev/functions/controller/authUser.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('Register Page', style: TextStyle(fontSize: 24)),
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
            const Label(text: 'Correo: ', color: Colors.black, fontSize: 15),
            Input(
              placeholder: 'Ingrese su correo',
              isPassword: false,
              controller: _emailController,
              labelColor: Colors.black,
              icon: const Icon(Icons.email),
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
            const Label(
                text: 'Confirmar Contraseña: ',
                color: Colors.black,
                fontSize: 15),
            Input(
              placeholder: 'Confirme su contraseña',
              isPassword: true,
              controller: _confirmController,
              labelColor: Colors.black,
              icon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Button(
                    text: 'Registrarse',
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () async {
                      final Map<String, dynamic> response = await register(
                        _emailController.text,
                        _usernameController.text,
                        _passwordController.text,
                        _confirmController.text,
                      );

                      if (response['success'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['success']),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['error']),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¿Ya tienes una cuenta?'),
            Link(text: 'Iniciar Sesión', url: '/')
          ],
        ),
      ),
    );
  }
}
