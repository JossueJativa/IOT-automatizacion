import 'dart:convert';

import 'package:front_dev/functions/jsonConvert.dart';
import 'package:front_dev/functions/tokenPhone.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

Future<Map<String, dynamic>> register(
    String email, String username, String password, String confirm) async {
  if (password != confirm) {
    return {'error': 'Las contraseñas no coinciden'};
  }

  final tokenPhone = await getTokenPhone();

  if (tokenPhone == null) {
    return {'error': 'No se pudo obtener el token del teléfono'};
  }

  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}user/';

  final response = await http.post(Uri.parse(url), body: {
    'username': username,
    'email': email,
    'password': password,
    'confirm': confirm,
    'tokenPhone': tokenPhone,
  });

  if (response.statusCode == 200) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final reqResponse = await jsonDecode(response.body);
    pref.setString('refresh', reqResponse['refresh']);
    pref.setString('access', reqResponse['access']);

    return {'success': 'Usuario registrado correctamente'};
  } else {
    return {'error': 'Error al registrar el usuario'};
  }
}

Future<Map<String, dynamic>> login(String username, String password) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}user/login/';

  final response = await http.post(Uri.parse(url), body: {
    'username': username,
    'password': password,
  });

  if (response.statusCode == 200) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final reqResponse = await jsonDecode(response.body);

    pref.setString('refresh', reqResponse['refresh']);
    pref.setString('access', reqResponse['access']);

    return {'success': 'Inicio Exitoso'};
  } else {
    return {'error': 'Error al iniciar sesión'};
  }
}

Future<Map<String, dynamic>> refreshToken(String refresh) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}token/refresh/';

  final response = await http.post(Uri.parse(url), body: {
    'refresh': refresh,
  });

  if (response.statusCode == 200) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final reqResponse = jsonDecode(response.body);
    await pref.setString('refresh', reqResponse['refresh']);
    await pref.setString('access', reqResponse['access']);

    return {'success': 'Token actualizado', 'access_token': reqResponse['access']};
  } else {
    return {'error': 'Error al actualizar el token'};
  }
}

Future<Map<String, dynamic>> verifyAndRefreshToken(String refresh) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String verifyUrl = '${data['API_URL']}token/verify/';

  final responseVerify = await http.post(Uri.parse(verifyUrl), body: {
    'token': refresh,
  });

  if (responseVerify.statusCode == 200) {
    return {'success': 'Token válido y verificado'};
  } else {
    final refreshResult = await refreshToken(refresh);

    if (refreshResult.containsKey('success')) {
      return {'success': 'Token inválido, pero se ha actualizado', 'access_token': refreshResult['access_token']};
    } else {
      return {'error': 'Token inválido y no se pudo actualizar'};
    }
  }
}

Future<bool> logout() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove('refresh');
  pref.remove('access');
  return true;
}

Future<int> getIdUser() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final String? access = pref.getString('access');

  if (access == null) {
    throw Exception('Access token no encontrado');
  }

  final Map<String, dynamic> payload = Jwt.parseJwt(access);
  return payload['user_id'];
}
