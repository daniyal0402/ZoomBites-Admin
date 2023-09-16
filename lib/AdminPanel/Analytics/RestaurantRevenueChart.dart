import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueChart extends StatefulWidget {
  @override
  _RevenueChartState createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Order> orders = [];
  List<String> months = [];
  String? selectedMonth;
  Map<String, double> restaurantRevenue = {};

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
        restaurantRevenue[restaurantId] =
            (restaurantRevenue[restaurantId] ?? 0) + order.grandTotal;
      }
    });

    setState(() {});
  }

  ViewDetails() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Restaurants Revenue"),
          content: Container(
            width: MediaQuery.of(context)
                .size
                .width, // Set a width that suits your design
            height: MediaQuery.of(context)
                .size
                .height, // Set a height that suits your design
            child: ListView.builder(
              itemCount: restaurantRevenue.length,
              itemBuilder: (BuildContext context, int index) {
                final restaurantName = restaurantRevenue.keys.elementAt(index);
                final revenue = restaurantRevenue.values.elementAt(index);

                return ListTile(
                  title: Text(restaurantName),
                  subtitle: Text(
                    '\$${revenue.toStringAsFixed(2)}', // Format revenue as currency
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
                    restaurantRevenue.clear();
                    orders.forEach((order) {
                      final monthYear = order.orderDateTime
                          .toDate()
                          .toString()
                          .substring(0, 7);
                      if (monthYear == selectedMonth) {
                        final restaurantId = order.restaurant['name'];
                        restaurantRevenue[restaurantId] =
                            (restaurantRevenue[restaurantId] ?? 0) +
                                order.grandTotal;
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
                text: "Restaurants Revenue Generation",
                textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            legend: const Legend(
                isVisible: true, textStyle: TextStyle(color: Colors.white)),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: restaurantRevenue.entries
                    .map((entry) => ChartData(entry.key, entry.value.toInt()))
                    .toList(),
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                dataLabelSettings: const DataLabelSettings(
                    isVisible: true, color: Colors.white),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: ViewDetails,
            child: const Text("View List"),
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
