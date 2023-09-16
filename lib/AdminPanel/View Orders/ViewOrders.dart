import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_management/API/firebaseApi.dart';

class ViewOrders extends StatefulWidget {
  @override
  _ViewOrdersState createState() => _ViewOrdersState();
}

class _ViewOrdersState extends State<ViewOrders> {
  DateTime selectedDate = DateTime.now().subtract(Duration(
    hours: DateTime.now().hour,
    minutes: DateTime.now().minute,
    seconds: DateTime.now().second,
    milliseconds: DateTime.now().millisecond,
    microseconds: DateTime.now().microsecond,
  ));
  String selectedStatus = "New"; // Default status filter
  List<String> statusOptions = [
    "New",
    "Cancelled",
    "Viewed",
    "Completed",
    "Dispatched"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('View Orders')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  children: [
                    // Date Picker
                    Expanded(
                      child: DatePicker(
                        selectedDate: selectedDate,
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // Status Filter Dropdown
                    DropdownButton<String>(
                      dropdownColor: Colors.grey[800],
                      value: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                      items: statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Create a stream to listen for changes in orders collection
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('orderDateTime', isGreaterThanOrEqualTo: selectedDate)
                  .where('orderDateTime',
                      isLessThan: selectedDate.add(Duration(days: 1)))
                  .where('status', isEqualTo: selectedStatus)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Display the orders in a ListView
                return Card(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot order = snapshot.data!.docs[index];
                        return Container(
                          color:
                              index % 2 == 0 ? Colors.grey[800] : Colors.black,
                          child: ListTile(
                            title: Text(
                                'Restaurant: ${order['restaurant']['name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: ${order['customer']['name']}'),
                                Text('Grand Total: \$${order['grandTotal']}'),
                                Text(
                                    'Order Date: ${order['orderDateTime'].toDate()}'),
                              ],
                            ),
                            onTap: () {
                              ViewOrderDialog(order);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ViewOrderDialog(final order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            textAlign: TextAlign.center,
            'Order Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Customer Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Name: ${order['customer']['name']}'),
                Text('Number: ${order['customer']['number']}'),
                Text('Adress: ${order['customer']['address']}'),
                const SizedBox(
                  height: 16,
                ),
                const Center(
                  child: Text(
                    "Restaurant Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Name: ${order['restaurant']['name']}'),
                Text('Number: ${order['restaurant']['number']}'),
                Text('Location: ${order['restaurant']['location']}'),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(order['orderItems'].length, (index) {
                    final item = order['orderItems'][index];
                    return ListTile(
                      title: Text(item['itemName']),
                      subtitle: Text('Price: \$${item['itemPrice']}'),
                      trailing: Text('Quantity: ${item['quantity']}'),
                    );
                  }),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    textAlign: TextAlign.end,
                    'Total: \$${order['total']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    textAlign: TextAlign.end,
                    'Tax: \$${order['tax']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    textAlign: TextAlign.end,
                    'Delivery Charges: \$${order['deliveryCharges']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    textAlign: TextAlign.end,
                    'Grand Total: \$${order['grandTotal']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    textAlign: TextAlign.end,
                    'Order Date: ${order['orderDateTime'].toDate()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                showDialog(
                  context: dialogContext,
                  builder: (BuildContext confirmationContext) {
                    return AlertDialog(
                      title: const Text('Confirm Cancellation'),
                      content: const Text(
                        'Are you sure you want to cancel this order?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(confirmationContext).pop();
                            Navigator.of(dialogContext).pop();

                            // Update the order status to "Cancelled" in Firestore here
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(order
                                    .id) // Use the ID of the order document
                                .update({'status': 'Cancelled'});

                            sendNotification(
                                order['restaurant']['key'],
                                "Order Cancelled",
                                "An order has been cancelled!");
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(confirmationContext).pop();
                          },
                          child: const Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Cancel Order'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  DatePicker({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null && picked != selectedDate) {
            onDateChanged(picked);
          }
        },
        child: Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
