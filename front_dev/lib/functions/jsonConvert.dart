import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadAuthData() async {
  String jsonString = await rootBundle.loadString('assets/auth.json');
  Map<String, dynamic> jsonData = jsonDecode(jsonString);

  return jsonData;
}