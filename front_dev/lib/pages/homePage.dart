import 'package:flutter/material.dart';
import 'package:front_dev/common/button.dart';
import 'package:front_dev/common/input.dart';
import 'package:front_dev/common/label.dart';
import 'package:front_dev/common/popUp.dart';
import 'package:front_dev/functions/controller/IOTController.dart';
import 'package:front_dev/functions/controller/devicesController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? _prefs;
  bool _haAdded = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _devicesFuture = fetchDevices();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _haAdded = _prefs?.getBool('HA_added') ?? false;
    });
  }

  Future<void> _addHomeAssistant() async {
    await addHomeAssistant(_urlController.text, _tokenController.text);
    await _prefs?.setBool('HA_added', true);
    setState(() {
      _haAdded = true;
    });
    Navigator.pop(context);
  }

  Future<List<Map<String, dynamic>>> fetchDevices() async {
    return await getDevicesHA(1);
  }

  Future<void> _addDevice() async {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => PopUp(
        title: 'Agregar dispositivo',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Label(
              text: 'Nombre del dispositivo',
              color: Colors.black,
              fontSize: 16,
            ),
            Input(
              placeholder: 'Nombre del dispositivo',
              isPassword: false,
              controller: nameController,
              labelColor: Colors.black,
              icon: const Icon(Icons.add_box),
            ),
          ],
        ),
        pstCallback: () async {
          SharedPreferences pref = await SharedPreferences.getInstance();
          final int idHA = pref.getInt('idHA')!;
          await addDevice(idHA, nameController.text);
          Navigator.pop(context);
          setState(() {
            _devicesFuture = fetchDevices();
          });
        },
        ngtCallback: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          if (!_haAdded)
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => PopUp(
                  title: 'Agregar Home Assistant',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Label(
                        text: 'Url de Home Assistant',
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      Input(
                        placeholder: 'Url de Home Assistant',
                        isPassword: false,
                        controller: _urlController,
                        labelColor: Colors.black,
                        icon: const Icon(Icons.home),
                      ),
                      const SizedBox(height: 10),
                      Label(
                        text: 'Token de Home Assistant',
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      Input(
                        placeholder: 'Token de Home Assistant',
                        isPassword: false,
                        controller: _tokenController,
                        labelColor: Colors.black,
                        icon: const Icon(Icons.lock),
                      ),
                    ],
                  ),
                  pstCallback: _addHomeAssistant,
                  ngtCallback: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Button(
                text: 'Agregar dispositivo',
                color: Colors.green,
                textColor: Colors.white,
                onPressed: _addDevice,
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index == snapshot.data!.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: _addDevice,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Agregar dispositivo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  final device = (snapshot.data![index]);
                  final nameDevice = device['attributes']?['friendly_name'] ?? 'Desconocido';
                  final entityId = device['entity_id'] ?? 'Sin ID';
                  final state = device['state'] ?? 'Desconocido';


                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          'device/',
                          arguments: {
                            'deviceId': index + 1,
                            'entityId': entityId,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            nameDevice ?? 'Desconocido',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ID: $entityId',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Estado: $state',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
