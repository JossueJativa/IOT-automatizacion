import 'dart:convert';

import 'package:front_dev/functions/controller/IOTController.dart';
import 'package:front_dev/functions/controller/authUser.dart';
import 'package:front_dev/functions/jsonConvert.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getDevices() async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return [{'error': 'No se pudo obtener la URL de la API'}];
  }

  if (data.isEmpty) {
    return [{'error': 'No se pudo obtener la URL de la API'}];
  }

  final int userId = await getIdUser();

  final String url = '${data['API_URL']}user/$userId/';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> userData = jsonDecode(response.body);

    if (userData['devices'] == null) {
      return [{'error': 'No se encontraron dispositivos en el usuario'}];
    }

    List<int> deviceIds = List<int>.from(userData['devices']);
    List<Map<String, dynamic>> devices = [];

    for (var deviceId in deviceIds) {
      final responseDevice = await http.get(Uri.parse('${data['API_URL']}devices/$deviceId/'));

      if (responseDevice.statusCode == 200) {
        Map<String, dynamic> device = jsonDecode(responseDevice.body);
        devices.add(device);
      } else {
        return [{'error': 'Error al obtener el dispositivo $deviceId'}];
      }
    }
    return devices;

  } else {
    return [{'error': 'Error al obtener el usuario'}];
  }
}

Future<Map<String,String>> addDevice(int homeassistantId, String name) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devices/';

  final history = await addHistory(true, 'Dispositivo añadido');

  if (history['error'] != null) {
    return {'error': 'Error al añadir historial'};
  }

  final response = await http.post(Uri.parse(url), body: {
    'homeassistant': homeassistantId.toString(),
    'name': name,
    'history': history['id'],
  });

  if (response.statusCode == 201) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final int deviceId = body['id'];
    final responseAdd = await addDeviceUser(deviceId);

    if (responseAdd) {
      return {'success': 'Dispositivo añadido correctamente'};
    } else {
      return {'error': 'Error al añadir dispositivo'};
    }
  } else {
    return {'error': 'Error al añadir dispositivo'};
  }
}

Future<bool> addDeviceUser(int deviceId) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return false;
  }

  if (data.isEmpty) {
    return false;
  }

  final int userId = await getIdUser();

  final String url = '${data['API_URL']}user/$userId/';

  final responseGet = await http.get(Uri.parse(url));

  if (responseGet.statusCode != 200) {
    return false;
  }

  final Map<String, dynamic> user = jsonDecode(responseGet.body);
  final List<dynamic> devices = List.from(user['devices'] ?? []);

  if (devices.contains(deviceId)) {
    return false;
  }

  devices.add(deviceId);
  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'devices': devices,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<Map<String, dynamic>>getDeviceHistory(int id) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devices/$id/';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {'error': 'Error al obtener el dispositivo'};
  }
}

Future<Map<String, dynamic>>updateHistory(int deviceId, bool state, String description) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  if (data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devicehistory/';

  final response = await http.post(
    Uri.parse(url),
    body: {
      'state': state.toString(),
      'description': description,
    },
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final int historyId = body['id'];

    final responseDevice = await http.get(Uri.parse('${data['API_URL']}devices/$deviceId/'));

    if (responseDevice.statusCode == 200) {
      final Map<String, dynamic> device = jsonDecode(responseDevice.body);
      final List<dynamic> history = List.from(device['device']['history'] ?? []);
      history.add(historyId);

      final responseUpdate = await http.patch(
        Uri.parse('${data['API_URL']}devices/$deviceId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'history': history,
        }),
      );

      if (responseUpdate.statusCode == 200) {
        return {'success': 'Historial actualizado correctamente'};
      } else {
        return {'error': 'Error al actualizar el historial'};
      }
    } else {
      return {'error': 'Error al obtener el dispositivo'};
    }
  } else {
    return {'error': 'Error al actualizar el historial'};
  }
}

Future<Map<String, dynamic>> getEnergy(int id) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devices/generate_energy/?device_id=$id';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body;
  } else {
    return {'error': 'Error al obtener el dispositivo'};
  }
}

Future<Map<String, dynamic>> getPower(int id) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devices/generate_power/?device_id=$id';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body;
  } else {
    return {'error': 'Error al obtener el dispositivo'};
  }
}

Future<Map<String, dynamic>> calculateEnergyCost(int id) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return {'error': 'No se pudo obtener la URL de la API'};
  }

  final String url = '${data['API_URL']}devices/generate_energy/?device_id=$id';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['error'] != null) {
      return {'error': 'Error al obtener el consumo de energía'};
    }

    final Map<String, dynamic> energyHour = body['energy_hour'];
    const double pricePerUnit = 0.15; // Precio estático por unidad de energía
    double totalCost = 0;

    energyHour.forEach((hour, energy) {
      totalCost += energy * pricePerUnit;
    });

    return {
      'message': 'Costo de energía calculado con éxito',
      'total_cost': totalCost,
      'energy_hour': energyHour
    };
  } else {
    return {'error': 'Error al obtener el dispositivo'};
  }
}

Future<List<Map<String, dynamic>>> getDevicesHA(int homeassistant_id) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return [{'error': 'No se pudo obtener la URL de la API'}];
  }

  final String url = '${data['API_URL']}devices/get_devices/?homeassistant_id=$homeassistant_id';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decodifica la respuesta
      final dynamic decodedResponse = jsonDecode(response.body);

      // Verifica si es un mapa con una lista de dispositivos
      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('devices')) {
        final List<dynamic> devices = decodedResponse['devices'];

        // Filtra los dispositivos tipo "switch" y "light"
        final switchDevices = devices
            .where((device) => device['entity_id'].startsWith('switch.'))
            .toList();
        final lightDevices = devices
            .where((device) => device['entity_id'].startsWith('light.'))
            .toList();

        return [...switchDevices, ...lightDevices];
      } else if (decodedResponse is List) {
        // Si ya es una lista directamente
        final switchDevices = decodedResponse
            .where((device) => device['entity_id'].startsWith('switch.'))
            .toList();
        final lightDevices = decodedResponse
            .where((device) => device['entity_id'].startsWith('light.'))
            .toList();

        return [...switchDevices, ...lightDevices];
      } else {
        return [{'error': 'Formato de respuesta inesperado'}];
      }
    } else {
      return [{'error': 'Error al obtener los dispositivos'}];
    }
  } catch (e) {
    return [{'error': 'Error al procesar la solicitud: $e'}];
  }
}

Future<bool> change_status(String message, String entityId) async {
  final Map<String, dynamic> data = await loadAuthData();

  if (data['API_URL'] == null || data.isEmpty) {
    return false;
  }

  final String url = '${data['API_URL']}devices/call_service/';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'type': 'call_service',
      'domain': 'switch',
      'service': message,
      'service_data': {
        'entity_id': entityId,
      },
      'homeassistant_id': 1,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}