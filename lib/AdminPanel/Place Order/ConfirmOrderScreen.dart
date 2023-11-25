import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management/AdminPanel/MainScreen.dart';
import 'package:restaurant_management/Helpers/Helpers.dart';

import '../../API/firebaseApi.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  ConfirmOrderScreen({required this.orderData});
  @override
  ConfirmOrderScreenState createState() =>
      ConfirmOrderScreenState(orderData: orderData);
}

class ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool isLoading = false;
  final Map<String, dynamic> orderData;

  ConfirmOrderScreenState({required this.orderData});
  void _saveOrderToFirestore() async {
    setState(() {
      isLoading = true;
    });
    if (await checkConnectivity() == false)
      showToast(context, "Not connected to internet!");
    else {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        orderData['orderDateTime'] = FieldValue.serverTimestamp();
        orderData['status'] = "New";
        await firestore.collection('orders').add(orderData).then((value) {
          showToast(context, "Order Placed Successfully");
        });

        await EditCustomerStats();

        sendNotification(orderData['restaurant']['key'], "New Order",
            "You have recieved a new order. tap to open the app");
      } catch (e) {
        showToast(context, e.toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  EditCustomerStats() async {
    FirebaseFirestore.instance
        .collection('customers')
        .doc(orderData['customer']['id'])
        .update({
      'lastOrdered': DateTime.now(),
      'numberOfTimesOrdered': orderData['customer']['numberOfTimesOrdered'] + 1,
      'totalExpenditure':
          orderData['customer']['totalExpenditure'] + orderData['grandTotal'],
    });
    updateOrAddRestaurantCounter(orderData['customer']['id'],
        orderData['restaurant']['id'], orderData['restaurant']['name']);
  }

  Future<void> updateOrAddRestaurantCounter(
    String documentID,
    String restaurantID,
    String restaurantName, // You may need to pass this if you have it.
  ) async {
    int counter = 0;
    bool found = false;
    for (int i = 0;
        i < orderData['customer']['listOfRestaurantsOrderedFrom'].length &&
            found == false;
        i++) {
      if (orderData['customer']['listOfRestaurantsOrderedFrom'][i]
              ['restaurantID'] ==
          restaurantID) {
        counter =
            orderData['customer']['listOfRestaurantsOrderedFrom'][i]['counter'];
        found = true;
      }
    }
    print(found);
    counter++;
    updateRestaurantsOrderedFrom(
        documentID, restaurantID, restaurantName, counter);
  }

  Future<bool> updateRestaurantsOrderedFrom(
      String docId, String resID, String resName, int counter) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (resID.isNotEmpty && resName.isNotEmpty) {
        final doc = firestore.collection('customers').doc(docId);
        final customersSnapshot = await doc.get();

        // Check if the item already exists in the menu
        final existingResOrderedFrom =
            customersSnapshot.data()?['listOfRestaurantsOrderedFrom'] ?? [];

        print(customersSnapshot.data());

        // Find the index of the existing item with the same restaurantID
        final duplicateIndex = existingResOrderedFrom
            .indexWhere((item) => item['restaurantID'] == resID);

        if (duplicateIndex != -1) {
          // Update the counter of the existing item
          existingResOrderedFrom[duplicateIndex]['counter'] = counter;

          await doc.update({
            'listOfRestaurantsOrderedFrom': existingResOrderedFrom,
          });

          // Return true when the counter is updated for the duplicate
          return true;
        } else {
          await doc.update({
            'listOfRestaurantsOrderedFrom': FieldValue.arrayUnion([
              {
                'restaurantID': resID,
                'restaurantName': resName,
                'counter': counter,
              },
            ]),
          });
          // Return true only when the update is successful and not a duplicate
          return true;
        }
      }
      // Return false if menuItem or menuPrice is empty
      return false;
    } catch (e) {
      // Handle any errors here, you can print or log them if needed
      print('Error adding/updating menu item: $e');
      return false; // Return false if an error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              textAlign: TextAlign.start,
                              'Customer Details:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text('ID: ${orderData['customer']['id']}'),
                            Text('Name: ${orderData['customer']['name']}'),
                            Text(
                                'Address: ${orderData['customer']['address']}'),
                            Text('Number: ${orderData['customer']['number']}'),
                            Text(
                                'Number: ${orderData['customer']['numberOfTimesOrdered']}'),
                            Text(
                                'Number: ${orderData['customer']['totalExpenditure']}'),
                            const SizedBox(height: 25),
                            const Text(
                              textAlign: TextAlign.start,
                              'Restaurant Details:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text('ID: ${orderData['restaurant']['id']}'),
                            // Text('Key: ${orderData['restaurant']['key']}'),
                            Text('Name: ${orderData['restaurant']['name']}'),
                            Text(
                                'Location: ${orderData['restaurant']['location']}'),
                            Text(
                                'Number: ${orderData['restaurant']['number']}'),
                            const SizedBox(height: 25),
                            const Text(
                              textAlign: TextAlign.start,
                              'Order Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: orderData['orderItems'].length,
                              itemBuilder: (context, index) {
                                final item = orderData['orderItems'][index];
                                return ListTile(
                                  title: Text(item['itemName']),
                                  subtitle:
                                      Text('Price: \$${item['itemPrice']}'),
                                  trailing:
                                      Text('Quantity: ${item['quantity']}'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Total: \$${orderData['total']}'),
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Tax: \$${orderData['tax']}'),
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Miscellenous Charges: \$${orderData['miscCharges']}'),
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Bottle Deposit: \$${orderData['bottleCharges']}'),
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Delivery Charges: \$${orderData['deliveryCharges']}'),
                        Text(
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            'Grand Total: \$${orderData['grandTotal']}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Save the order data to Firestore when the button is pressed
                            _saveOrderToFirestore();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text('Confirm Order'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
