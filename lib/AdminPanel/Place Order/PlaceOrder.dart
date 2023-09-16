import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_management/AdminPanel/Place%20Order/NewCustomer.dart';
import 'package:restaurant_management/AdminPanel/Place%20Order/SelectMenuScreen.dart';
import 'package:restaurant_management/Helpers/Helpers.dart';
import 'package:restaurant_management/Helpers/MyTextFields.dart';

import '../../Models/Customer.dart';

class PlaceOrder extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<PlaceOrder> {
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? selectedBirthday;
  List<Customer> _existingCustomers = [];
  List<Customer> _filteredCustomers = [];
  Customer? _selectedCustomer;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('customers').get();
    setState(() {
      _existingCustomers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Customer(
          id: doc.id,
          name: data['name'],
          number: data['number'],
          address: data['address'],
          numberOfTimesOrdered: data['numberOfTimesOrdered'],
          birthday: data['birthday'] != null
              ? (data['birthday'] as Timestamp).toDate()
              : null,
          region: data['region'],
          lastOrdered: (data['lastOrdered'] != null)
              ? (data['lastOrdered'] as Timestamp).toDate()
              : null,
          // lastOrdered: DateTime.now(),
          listOfRestaurantsOrderedFrom: List<Map<String, dynamic>>.from(
              data['listOfRestaurantsOrderedFrom']),
          totalExpenditure: (data['totalExpenditure'] ?? 0).toDouble(),
        );
      }).toList();
      _filteredCustomers = List.from(_existingCustomers);
    });
    setState(() {
      isLoading = false;
    });
  }

  void _showNewCustomerDialog() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddNewCustomer()));
  }

  void _filterCustomers(String partialName) {
    setState(() {
      _filteredCustomers = _existingCustomers.where((customer) {
        return customer.name.toLowerCase().contains(partialName.toLowerCase());
      }).toList();
    });
  }

  void CustomerNameEntered(value) {
    _filterCustomers(value);
    setState(() {
      _selectedCustomer = null;
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    MyTextField(
                      label: "Customer Name",
                      controller: _nameController,
                      func: CustomerNameEntered,
                    ),

                    const SizedBox(height: 16),
                    // Inside the build method, add this button
                    if (_selectedCustomer == null)
                      ElevatedButton(
                        onPressed: _showNewCustomerDialog,
                        child: const Text('New Customer'),
                      ),
                    _selectedCustomer != null
                        ? Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(
                                  child: Text(
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    'Selected Customer',
                                  ),
                                ),
                                MyTextField(
                                  label: 'Name',
                                  controller: _nameController,
                                  inputType: TextInputType.number,
                                  func: () {},
                                ),
                                MyTextField(
                                  label: 'Number',
                                  controller: _numberController,
                                  inputType: TextInputType.number,
                                  func: () {},
                                ),
                                MyTextField(
                                  label: 'Address',
                                  controller: _addressController,
                                  func: () {},
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 16),
                    if (_isEditMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (await checkConnectivity() == false) {
                                // ignore: use_build_context_synchronously
                                showToast(
                                    context, "Not connected to internet!");
                              }
                              // Update the selected customer's data in Firestore
                              if (_nameController.text == "" ||
                                  _numberController == "" ||
                                  _addressController == "") {
                                // ignore: use_build_context_synchronously
                                showToast(
                                    context, "Please enter valid values!");
                              } else {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(_selectedCustomer!.id)
                                      .update({
                                    'name': _nameController.text,
                                    'number': _numberController.text,
                                    'address': _addressController.text,
                                  }).then((value) {
                                    showToast(context,
                                        "Customer data updated successfully!");
                                  });
                                } catch (e) {
                                  showToast(context, e.toString());
                                }
                              }
                              setState(() {
                                _fetchCustomers();

                                _isEditMode = false;
                              });
                            },
                            child: const Text('Save Changes'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print(_selectedCustomer!.name);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectMenuScreen(
                                      customer: _selectedCustomer!),
                                ),
                              );
                            },
                            child: const Text('Proceed'),
                          ),
                        ],
                      ),
                    const Text('Existing Customers:'),
                    const SizedBox(height: 8),
                    Card(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: index % 2 == 0
                                  ? Colors.grey[800]
                                  : Colors.black,
                              child: ListTile(
                                title: Text(_filteredCustomers[index].name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Address: ${_filteredCustomers[index].address}'),
                                    Text(
                                        'Number of Orders: ${_filteredCustomers[index].numberOfTimesOrdered}'),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer =
                                        _filteredCustomers[index];
                                    _nameController.text =
                                        _filteredCustomers[index].name;
                                    _numberController.text =
                                        _filteredCustomers[index].number;
                                    _addressController.text =
                                        _filteredCustomers[index].address;
                                    _filteredCustomers = [];
                                    _isEditMode = true;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
