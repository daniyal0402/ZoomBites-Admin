import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:restaurant_management/API/firebaseFunctions.dart';

Future<void> loadCSV() async {
  String csvString = await rootBundle.loadString('assets/menu.csv');
  List<Map<dynamic, dynamic>> menuItems = [];

  List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

  List<String> headers = csvTable[0].map((dynamic e) => e.toString()).toList();

  for (int i = 1; i < csvTable.length; i++) {
    Map<dynamic, dynamic> menuItem = {};
    for (int j = 0; j < headers.length; j++) {
      if (headers[j] == "isBottle") {
        menuItem[headers[j]] = true;
      } else {
        menuItem[headers[j]] = csvTable[i][j].toString();
      }
    }

    menuItems.add(menuItem);
  }

  addMenuItemsTEmporary("7syKSKgxHPKcP3RtHRJV", menuItems);
}
