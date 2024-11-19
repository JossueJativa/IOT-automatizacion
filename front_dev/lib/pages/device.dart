import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_dev/functions/controller/devicesController.dart';
import 'package:fl_chart/fl_chart.dart';

class Device extends StatefulWidget {
  final int deviceId;
  const Device({super.key, required this.deviceId});

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  bool isDeviceOn = false;
  int temperature = 20;

  void toggleDeviceState() {
    setState(() {
      isDeviceOn = !isDeviceOn;
    });

    final String description = isDeviceOn ? 'The device is turned on' : 'The device is turned off';
    final bool state = isDeviceOn;

    updateHistory(
      widget.deviceId,
      state,
      description,
    );
  }

  List<FlSpot> generateChartData(List history) {
    return history.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      double state = item['state'] ? 1.0 : 0.0;
      return FlSpot(index.toDouble(), state);
    }).toList();
  }

  List<FlSpot> generateEnergyChartData(Map<String, dynamic> energyData) {
    return energyData.entries.map((entry) {
      int hour = int.parse(entry.key);
      double energy = entry.value.toDouble();
      return FlSpot(hour.toDouble(), energy);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device ${widget.deviceId}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getDeviceHistory(widget.deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data.containsKey('error')) {
              return Center(
                child: Text('Error: ${data['error']}'),
              );
            }

            final device = data['device'];
            final history = data['history'] as List;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Control'
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: isDeviceOn
                                    ? () {
                                        setState(() {
                                          if (temperature > 0) {
                                            temperature--;
                                          }
                                        });

                                        final String description = 'The temperature was set to $temperature°C';
                                        final bool state = isDeviceOn;

                                        updateHistory(
                                          widget.deviceId,
                                          state,
                                          description,
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$temperature°C',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                onPressed: isDeviceOn
                                    ? () {
                                        setState(() {
                                          if (temperature < 30) {
                                            temperature++;
                                          }
                                        });

                                        final String description = 'The temperature was set to $temperature°C';
                                        final bool state = isDeviceOn;

                                        updateHistory(
                                          widget.deviceId,
                                          state,
                                          description,
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: toggleDeviceState,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDeviceOn ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          isDeviceOn ? 'Turn Off' : 'Turn On',
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Device Info:'),
                          const SizedBox(height: 8),
                          Text('ID: ${device['id']}'),
                          Text('Name: ${device['name']}'),
                        ],
                      ),
                      FutureBuilder<Map<String, dynamic>>(
                        future: calculateEnergyCost(widget.deviceId),
                        builder: (context, energyCostSnapshot) {
                          if (energyCostSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (energyCostSnapshot.hasError) {
                            return Text('Error: ${energyCostSnapshot.error}');
                          } else if (energyCostSnapshot.hasData) {
                            final energyCostData = energyCostSnapshot.data!;
                            final totalCost = energyCostData['total_cost'];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Costo total del día: \$${totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            return const Text('No energy data found.');
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Text('Historial de Encendido/Apagado:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: generateChartData(history),
                            isStepLineChart: true,
                            barWidth: 2,
                            color: Colors.blueAccent,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                  const Divider(height: 24),

                  Text('Consumo de energía:'),
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, dynamic>>(
                    future: calculateEnergyCost(widget.deviceId),
                    builder: (context, energyCostSnapshot) {
                      if (energyCostSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (energyCostSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${energyCostSnapshot.error}'),
                        );
                      } else if (energyCostSnapshot.hasData) {
                        final energyCostData = energyCostSnapshot.data!;
                        final energyData = energyCostData['energy_hour'] as Map<String, dynamic>;
                        final totalCost = energyCostData['total_cost'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Costo total: \$${totalCost.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: generateEnergyChartData(energyData),
                                      isStepLineChart: false,
                                      barWidth: 2,
                                      color: Colors.green,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: Text('No energy data found.'));
                      }
                    },
                  ),
                  const Divider(height: 24),

                  Text('History:'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];

                        final description = Utf8Decoder().convert(
                            item['description'].toString().runes.toList());

                        return Card(
                          child: ListTile(
                            title:
                                Text(description),
                            subtitle: Text(
                              'Date: ${item['date']}\nState: ${item['state']}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}