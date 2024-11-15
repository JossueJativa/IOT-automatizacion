import 'dart:convert';

import 'package:front_dev/functions/jsonConvert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> addHomeAssistant(String urlHA, String token) async {
  final Map<String, dynamic> data = await loadAuthData();
  final SharedPreferences pref = await SharedPreferences.getInstance();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}homeassistant/';

  final response = await http.post(Uri.parse(url), body: {
    'url': urlHA,
    'token': token,
  });

  if (response.statusCode == 201) {
    Map<String, dynamic> body = jsonDecode(response.body);

    pref.setInt('idHA', body['id']);
    return {'success': 'Home Assistant añadido correctamente'};
  } else {
    return {'error': 'Error al añadir Home Assistant'};
  }
}

Future<Map<String, String>> addHistory(bool state, String description) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devicehistory/';

  final response = await http.post(Uri.parse(url), body: {
    'state': state.toString(),
    'description': description,
  });

  if (response.statusCode == 201) {
    Map<String, dynamic> body = jsonDecode(response.body);
    return {'success': 'Historial añadido correctamente', 'id': body['id'].toString()};
  } else {
    return {'error': 'Error al añadir historial'};
  }
}