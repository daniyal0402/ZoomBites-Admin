import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrderChart extends StatefulWidget {
  @override
  _OrderChartState createState() => _OrderChartState();
}

class _OrderChartState extends State<OrderChart> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Order> orders = [];
  List<String> months = [];
  String? selectedMonth;
  Map<String, int> restaurantCounts = {};

  // To store the currently tapped restaurant
  String? tappedRestaurant;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final QuerySnapshot orderSnapshot =
        await firestore.collection('orders').get();

    orders = orderSnapshot.docs
        .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Group orders by month
    orders.forEach((order) {
      final monthYear = order.orderDateTime.toDate().toString().substring(0, 7);
      if (!months.contains(monthYear)) {
        months.add(monthYear);
      }
      if (selectedMonth == null) {
        selectedMonth = monthYear;
      }
      if (monthYear == selectedMonth) {
        final restaurantId = order.restaurant['name'];
        restaurantCounts[restaurantId] =
            (restaurantCounts[restaurantId] ?? 0) + 1;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[800],
                value: selectedMonth,
                onChanged: (newMonth) {
                  setState(() {
                    selectedMonth = newMonth;
                    restaurantCounts.clear();
                    orders.forEach((order) {
                      final monthYear = order.orderDateTime
                          .toDate()
                          .toString()
                          .substring(0, 7);
                      if (monthYear == selectedMonth) {
                        final restaurantId = order.restaurant['name'];
                        restaurantCounts[restaurantId] =
                            (restaurantCounts[restaurantId] ?? 0) + 1;
                      }
                    });
                  });
                },
                items: months.map<DropdownMenuItem<String>>((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
              ),
            ),
          ),
          SfCircularChart(
            title: ChartTitle(
                text: "Restaurants market share",
                textStyle: TextStyle(fontWeight: FontWeight.bold)),
            legend: const Legend(
                isVisible: true, textStyle: TextStyle(color: Colors.white)),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: restaurantCounts.entries
                    .map((entry) => ChartData(entry.key, entry.value))
                    .toList(),
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                dataLabelSettings: const DataLabelSettings(
                    isVisible: true, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Order {
  final Map<String, dynamic> restaurant;
  final double grandTotal;
  final Timestamp orderDateTime;

  Order({
    required this.restaurant,
    required this.grandTotal,
    required this.orderDateTime,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      restaurant: map['restaurant'],
      grandTotal: map['grandTotal'],
      orderDateTime: map['orderDateTime'],
    );
  }
}

class ChartData {
  final String category;
  final int value;

  ChartData(this.category, this.value);
}
