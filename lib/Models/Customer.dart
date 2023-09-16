import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String number;
  final String address;
  final int numberOfTimesOrdered;
  final DateTime? birthday;
  final String region;
  final DateTime? lastOrdered;
  final List<Map<String, dynamic>> listOfRestaurantsOrderedFrom;
  final double totalExpenditure;

  Customer({
    required this.id,
    required this.name,
    required this.number,
    required this.address,
    required this.numberOfTimesOrdered,
    required this.birthday,
    required this.region,
    required this.lastOrdered,
    required this.listOfRestaurantsOrderedFrom,
    required this.totalExpenditure,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'number': number,
      'address': address,
      'numberOfTimesOrdered': numberOfTimesOrdered,
      'birthday': birthday,
      'region': region,
      'lastOrdered': lastOrdered,
      'listOfRestaurantsOrderedFrom': listOfRestaurantsOrderedFrom,
      'totalExpenditure': totalExpenditure,
    };
  }
}
