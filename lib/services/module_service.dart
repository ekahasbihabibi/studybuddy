import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/module.dart';

Future<List<Module>> loadModules() async {
  try {
    // Membaca file JSON dari assets
    final String jsonString = await rootBundle.loadString('assets/data/modules.json');

    // Decode JSON ke list dynamic
    final List<dynamic> jsonData = json.decode(jsonString);

    // Ubah menjadi list Module
    return jsonData.map((item) => Module.fromJson(item)).toList();
  } catch (e) {
    print('Gagal memuat modul: $e');
    return []; // Kembalikan list kosong jika gagal
  }
}
