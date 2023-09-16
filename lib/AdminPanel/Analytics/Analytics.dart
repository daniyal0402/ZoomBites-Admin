import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_management/AdminPanel/Analytics/RestaurantRevenueChart.dart';
import 'package:restaurant_management/AdminPanel/Analytics/RestaurantsAnalysis.dart';

class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<Map<String, dynamic>> lowSpendingCustomers = [];
  List<Map<String, dynamic>> mediumSpendingCustomers = [];
  List<Map<String, dynamic>> highSpendingCustomers = [];
  List<Map<String, dynamic>> lostCustomers = [];

  Map<String, bool> isExpanded = {
    'Low Spending Customers (0-50)': false,
    'Medium Spending Customers (50-100)': false,
    'High Spending Customers (100+)': false,
    'Customers that did not order since 2 weeks': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  void _fetchCustomerData() async {
    DateTime currentDate = DateTime.now();
    DateTime twoWeeksAgo = currentDate.subtract(Duration(days: 14));
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      List<Map<String, dynamic>> allCustomers = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> customerData = doc.data() as Map<String, dynamic>;
        double totalExpenditure = customerData['totalExpenditure'] ?? 0;
        int numberOfTimesOrdered = customerData['numberOfTimesOrdered'] ?? 0;

        double averageSpent = numberOfTimesOrdered > 0
            ? totalExpenditure / numberOfTimesOrdered
            : 0;

        customerData['averageSpent'] = averageSpent;

        allCustomers.add(customerData);

        DateTime lastOrdered;
        if (customerData['lastOrdered'] is Timestamp) {
          lastOrdered = (customerData['lastOrdered'] as Timestamp).toDate();
        } else {
          lastOrdered = DateTime
              .now(); // Use a default value if 'lastOrdered' is not a Timestamp
        }

        if (lastOrdered.isBefore(twoWeeksAgo)) {
          lostCustomers.add(customerData);
        }
      }

      // Sort customers into different spending ranges
      for (var customer in allCustomers) {
        if (customer['averageSpent'] >= 0 && customer['averageSpent'] < 50) {
          lowSpendingCustomers.add(customer);
        } else if (customer['averageSpent'] >= 50 &&
            customer['averageSpent'] < 100) {
          mediumSpendingCustomers.add(customer);
        } else {
          highSpendingCustomers.add(customer);
        }
      }

      // Sort each list by average spending in descending order
      lowSpendingCustomers.sort((a, b) =>
          b['averageSpent'].toDouble().compareTo(a['averageSpent'].toDouble()));
      mediumSpendingCustomers.sort((a, b) =>
          b['averageSpent'].toDouble().compareTo(a['averageSpent'].toDouble()));
      highSpendingCustomers.sort((a, b) =>
          b['averageSpent'].toDouble().compareTo(a['averageSpent'].toDouble()));
      lostCustomers.sort((a, b) =>
          b['averageSpent'].toDouble().compareTo(a['averageSpent'].toDouble()));

      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', textAlign: TextAlign.right),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderChart(),
            RevenueChart(),
            _buildCustomerList(
              'Low Spending Customers (0-50)',
              lowSpendingCustomers,
            ),
            _buildCustomerList(
              'Medium Spending Customers (50-100)',
              mediumSpendingCustomers,
            ),
            _buildCustomerList(
              'High Spending Customers (100+)',
              highSpendingCustomers,
            ),
            _buildCustomerList(
              'Customers that did not order since 2 weeks',
              lostCustomers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(
      String title, List<Map<String, dynamic>> customers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            setState(() {
              isExpanded[title] = !isExpanded[title]!;
            });
          },
          trailing: Icon(
            isExpanded[title]! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          ),
        ),
        if (isExpanded[title]!)
          Column(
            children: [
              SizedBox(height: 10.0),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: customers.length >= 5 ? 5 : customers.length,
                itemBuilder: (context, index) {
                  var customer = customers[index];
                  return ListTile(
                    title: Text(customer['name']),
                    subtitle: Text(
                      'Number: ${customer['number']}\nAverage Spent: \$${customer['averageSpent'].toStringAsFixed(2)}',
                    ),
                    onTap: () {
                      _showCustomerDetails(customer);
                    },
                  );
                },
              ),
              SizedBox(height: 10.0),
              if (customers.length > 5)
                ElevatedButton(
                  onPressed: () {
                    _showFullListDialog(title, customers);
                  },
                  child: const Text('View Entire List'),
                ),
              Divider(),
            ],
          ),
      ],
    );
  }

  void _showFullListDialog(String title, List<Map<String, dynamic>> customers) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                var customer = customers[index];
                return ListTile(
                  title: Text(customer['name']),
                  subtitle: Text(
                    'Number: ${customer['number']}\nAverage Spent: \$${customer['averageSpent'].toStringAsFixed(2)}',
                  ),
                  onTap: () {
                    _showCustomerDetails(customer);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    var restaurantsOrderedFrom =
        (customer['listOfRestaurantsOrderedFrom'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Customer Details")),
          content: SingleChildScrollView(
              child: ListTile(
            title: Center(child: Text(customer['name'])),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text('Address: ${customer['address']}'),
                const SizedBox(height: 5),
                Text('Number: ${customer['number']}'),
                const SizedBox(height: 5),
                Text('Region: ${customer['region']}'),
                const SizedBox(height: 5),
                Text(
                    'Number of Times Ordered: ${customer['numberOfTimesOrdered']}'),
                const SizedBox(height: 5),
                Text(
                    'Total Expenditure: \$${customer['totalExpenditure'].toStringAsFixed(2)}'),
                const SizedBox(height: 5),
                Text(
                    'Last Ordered: ${DateFormat('yyyy-MM-dd').format((customer['lastOrdered'] as Timestamp).toDate())}'),
                const SizedBox(height: 5),
                Text(
                    'Birthday: ${DateFormat('yyyy-MM-dd').format((customer['birthday'] as Timestamp).toDate())}'),
                const SizedBox(height: 15),
                const Text(
                  'Restaurants Ordered From:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: restaurantsOrderedFrom.map((restaurant) {
                    return Text(
                      '- ${restaurant['restaurantName']} (Count: ${restaurant['counter']})',
                    );
                  }).toList(),
                ),
              ],
            ),
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
