import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_management/AdminPanel/Place%20Order/ConfirmOrderScreen.dart';
import 'package:restaurant_management/Helpers/Helpers.dart';
import 'package:restaurant_management/Helpers/MyTextFields.dart';
import 'package:restaurant_management/Models/Customer.dart';

import '../../Models/Restaurants.dart';

class SelectMenuScreen extends StatefulWidget {
  final Customer customer;

  const SelectMenuScreen({required this.customer});

  @override
  _SelectMenuScreenState createState() => _SelectMenuScreenState();
}

class _SelectMenuScreenState extends State<SelectMenuScreen> {
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _quantityControllers = {};
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  final CollectionReference miscCollection =
      FirebaseFirestore.instance.collection('misc');
  double? taxValue;
  double? deliveryChargesValue;
  double grandTotal = 0.0;
  double taxAmount = 0.0;
  double total = 0.0;

  Restaurant? _selectedRestaurant; // To store the selected restaurant

  @override
  void initState() {
    super.initState();

    _fetchRestaurants();
  }

  @override
  void dispose() {
    // Dispose of the quantity controllers to avoid memory leaks
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fetchRestaurants() async {
    setState(() {
      isLoading = true;
    });
    fetchMiscData();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('active', isEqualTo: true)
        .get();
    setState(() {
      _restaurants = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> menuData =
            List<Map<String, dynamic>>.from(data['menu']);
        List<Map<String, dynamic>> menu = menuData.map((menuEntry) {
          return {
            'item': menuEntry['item'],
            'price': menuEntry['price'],
            'description': menuEntry['description'],
          };
        }).toList();

        return Restaurant(
          key: data['key'],
          location: data['location'],
          menu: menu,
          name: data['name'],
          number: data['number'],
          id: doc.id,
        );
      }).toList();
    });
    _filterRestaurants("");
    setState(() {
      isLoading = false;
    });
  }

  void _filterRestaurants(String partialName) {
    setState(() {
      _filteredRestaurants = _restaurants.where((restaurant) {
        return restaurant.name
            .toLowerCase()
            .contains(partialName.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Select Menu')),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedRestaurant != null
              ? _buildRestaurantDetails() // Show restaurant details if selected
              : _buildRestaurantList(), // Show restaurant list otherwise
    );
  }

  Widget _buildRestaurantList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: MyTextField(
              label: 'Search Restaurant',
              controller: _searchController,
              func: _filterRestaurants,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.amber,
                    child: ListView.builder(
                      itemCount: _filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey[800]
                                : Colors.black,
                          ),
                          child: ListTile(
                            title: Text(_filteredRestaurants[index].name),
                            subtitle:
                                Text(_filteredRestaurants[index].location),
                            onTap: () {
                              setState(() {
                                _selectedRestaurant =
                                    _filteredRestaurants[index];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool checkInputs(double quantity) {
    if (quantity >= 0) return true;
    return false;
  }

  Widget _buildRestaurantDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Text('Restaurant: ${_selectedRestaurant!.name}'),
        ),
        Center(child: Text('Location: ${_selectedRestaurant!.location}')),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: ListView.builder(
                itemCount: _selectedRestaurant!.menu.length,
                itemBuilder: (context, index) {
                  final menuEntry = _selectedRestaurant!.menu[index];
                  final itemName = menuEntry['item'];
                  final itemPrice = menuEntry['price'];
                  final itemDescription = menuEntry['description'];

                  // Create TextEditingController for quantity input
                  final quantityController =
                      _quantityControllers[itemName] ?? TextEditingController();
                  _quantityControllers[itemName] = quantityController;

                  return Container(
                    color: index % 2 == 0 ? Colors.grey[800] : Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itemName),
                              Text(itemDescription),
                              Text('Price: $itemPrice'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              setState(() {
                                // Handle quantity change and update the total
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Quantity'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text(
            textAlign: TextAlign.end,
            'Total: \$${_calculateTotal()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text(
            textAlign: TextAlign.end,
            'Tax: \$$taxAmount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text(
            textAlign: TextAlign.end,
            'Delivery Charges: \$$deliveryChargesValue',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text(
            textAlign: TextAlign.end,
            'Grand Total: \$$grandTotal',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedRestaurant =
                          null; // Clear the selected restaurant
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    bool legalValues = true;
                    // Build the order details
                    final List<Map<String, dynamic>> orderItems = [];
                    _selectedRestaurant!.menu.forEach((menuEntry) {
                      final itemName = menuEntry['item'];
                      final itemPrice = double.tryParse(menuEntry['price']);
                      final quantity = double.tryParse(
                              _quantityControllers[itemName]!.text) ??
                          0;

                      if (checkInputs(quantity)) {
                        if (quantity > 0) {
                          orderItems.add({
                            'itemName': itemName,
                            'itemPrice': itemPrice,
                            'quantity': quantity,
                          });
                        }
                      } else {
                        showInputError(context);
                        legalValues = false;
                      }
                    });

                    // Build the order data
                    final Map<String, dynamic> orderData = {
                      'customer': widget.customer.toMap(),
                      'restaurant': _selectedRestaurant!.toMap(),
                      'orderItems': orderItems,
                      'total': _calculateTotal(),
                      'grandTotal': grandTotal,
                      'tax': taxAmount,
                      'deliveryCharges': deliveryChargesValue,
                    };

                    // Navigate to the new screen with order data
                    if (legalValues) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConfirmOrderScreen(orderData: orderData),
                        ),
                      );
                    }
                  },
                  child: const Text('Place Order'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchMiscData() async {
    try {
      final DocumentSnapshot miscDoc =
          await miscCollection.doc('miscData').get();

      if (miscDoc.exists) {
        setState(() {
          taxValue = miscDoc['tax']?.toDouble();
          deliveryChargesValue = miscDoc['deliveryCharges']?.toDouble();
        });
      }
    } catch (e) {
      showToast(context, "Failed to retrieve tax and delivery charges");
    }
  }

  double _calculateTotal() {
    total = 0;
    taxAmount = 0;
    grandTotal = 0;
    for (var menuEntry in _selectedRestaurant!.menu) {
      final itemName = menuEntry['item'];
      final itemPrice = double.tryParse(menuEntry['price']);

      double? quantity = 0;
      if (_quantityControllers[itemName] != null) {
        if (_quantityControllers[itemName] != "") {
          quantity = double.tryParse(_quantityControllers[itemName]!.text);
        }
      }

      quantity ??= 0;

      total += double.tryParse((itemPrice! * quantity).toStringAsFixed(2))!;
      taxAmount =
          double.tryParse((total * taxValue! / 100).toStringAsFixed(2))!;
      grandTotal = double.tryParse(
          (total + taxAmount + deliveryChargesValue!).toStringAsFixed(2))!;
    }

    return total;
  }
}
