import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Helpers/Helpers.dart';
import '../../Helpers/MyTextFields.dart';
import '../../Models/Customer.dart';
import 'SelectMenuScreen.dart';

class AddNewCustomer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddNewCustomerState();
}

class AddNewCustomerState extends State<AddNewCustomer> {
  String newName = "";
  String newAddress = "";
  String newNumber = "";
  bool birthdaySelected = false;
  DateTime? selectedBirthday;
  String newRegion = "";
  List<Map<String, dynamic>> newListOfRestaurantsOrderedFrom = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Add New Customer"))),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextField(
                      label: 'Name',
                      controller: TextEditingController(text: newName),
                      func: (value) {
                        newName = value;
                      },
                    ),
                    MyTextField(
                      label: 'Address',
                      controller: TextEditingController(),
                      func: (value) {
                        newAddress = value;
                      },
                    ),
                    MyTextField(
                      label: 'Number',
                      inputType: TextInputType.number,
                      controller: TextEditingController(),
                      func: (value) {
                        newNumber = value;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectedBirthdayText(
                            selectedBirthday: selectedBirthday),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedBirthday = pickedDate;
                                birthdaySelected = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    MyTextField(
                      label: 'Region',
                      controller: TextEditingController(),
                      func: (value) {
                        newRegion = value;
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (CheckInput(
                      newName, newNumber, newAddress, birthdaySelected)) {
                    if (await checkConnectivity() == false) {
                      showToast(context, "Not connected to internet!");
                    } else {
                      try {
                        DocumentReference newCustomerRef =
                            await FirebaseFirestore.instance
                                .collection('customers')
                                .add({
                          'name': newName,
                          'address': newAddress,
                          'number': newNumber,
                          'numberOfTimesOrdered': 0,
                          'birthday': selectedBirthday != null
                              ? selectedBirthday!
                              : null,
                          'region': newRegion,
                          'lastOrdered': null,
                          'listOfRestaurantsOrderedFrom':
                              newListOfRestaurantsOrderedFrom,
                          'totalExpenditure': 0,
                        });

                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectMenuScreen(
                              customer: Customer(
                                id: newCustomerRef.id, // Store the ID
                                name: newName,
                                address: newAddress,
                                number: newNumber,
                                numberOfTimesOrdered: 0,
                                birthday: selectedBirthday!,
                                region: newRegion,
                                lastOrdered: null,
                                listOfRestaurantsOrderedFrom:
                                    newListOfRestaurantsOrderedFrom,
                                totalExpenditure: 0,
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        showToast(context, e.toString());
                      }
                    }
                  } else {
                    showInputError(context);
                  }
                },
                child: const Text('Save and Proceed'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedBirthdayText extends StatefulWidget {
  final DateTime? selectedBirthday;

  SelectedBirthdayText({required this.selectedBirthday});

  @override
  _SelectedBirthdayTextState createState() => _SelectedBirthdayTextState();
}

class _SelectedBirthdayTextState extends State<SelectedBirthdayText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Birthday: ${widget.selectedBirthday != null ? DateFormat('yyyy-MM-dd').format(widget.selectedBirthday!) : 'Not selected'}',
      style: TextStyle(color: Colors.teal[800], fontSize: 15),
    );
  }
}

bool CheckInput(
    String name, String number, String address, bool selectedBirthday) {
  if (name == "" ||
      number == "" ||
      address == "" ||
      selectedBirthday == false) {
    return false;
  }
  return true;
}
