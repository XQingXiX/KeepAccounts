import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';

class RwJson {
  Future<File> _getFile(String input) async {
    if (input == 'data') {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/data.json');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/config.json');
    }
  }

  Future<List<dynamic>> rJson() async {
    final file = await _getFile('data');
    if (!await file.exists()) {
      await file.writeAsString('[]');
      return [];
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    return jsonDecode(content) as List<dynamic>;
  }

  Future<void> wJson(Map<String, dynamic> record) async {
    final list = await rJson();
    list.add(record);
    final file = await _getFile('data');
    await file.writeAsString(jsonEncode(list));
  }

  Future<void> wJsonAll(List<dynamic> list) async {
    final file = await _getFile('data');
    await file.writeAsString(jsonEncode(list));
  }

  Future<Map<String, dynamic>> rConfig() async {
    final file = await _getFile('config');
    if (!await file.exists()) {
      await file.writeAsString('{"colors":"FFFFFFFF"}');
      return {"colors": "FFFFFFFF"};
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) return {};
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> wConfig(Color input) async {
    File file = await _getFile('config');
    final argb = input.toARGB32();
    final bkjson = await rConfig();
    bkjson["colors"] = argb.toRadixString(16).padLeft(8, '0').toUpperCase();
    await file.writeAsString(jsonEncode(bkjson));
  }
}
