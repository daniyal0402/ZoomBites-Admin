import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final Map<String, dynamic> restaurant;
  final double grandTotal;
  final double total;
  final double tax;
  final double deliveryCharges;

  final Timestamp orderDateTime;

  Order({
    required this.id,
    required this.restaurant,
    required this.grandTotal,
    required this.orderDateTime,
    required this.total,
    required this.tax,
    required this.deliveryCharges,
  });
}
