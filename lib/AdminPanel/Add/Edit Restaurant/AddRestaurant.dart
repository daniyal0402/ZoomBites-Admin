import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management/Helpers/Helpers.dart';
import 'package:restaurant_management/Helpers/MyTextFields.dart';

import '../../../API/firebaseFunctions.dart';

class AddRestaurant extends StatefulWidget {
  @override
  AddRestaurantState createState() => AddRestaurantState();
}

class AddRestaurantState extends State<AddRestaurant> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController menuItemController = TextEditingController();
  final TextEditingController menuPriceController = TextEditingController();
  bool isLoading = false;
  final TextEditingController menuDescriptionController =
      TextEditingController();
  final TextEditingController menuCategoryController = TextEditingController();

  @override
  initState() {
    super.initState();
    menuCategoryController.text = "bottle";
  }

  resetControllers() {
    nameController.text = "";
    numberController.text = "";
    userNameController.text = "";
    passwordController.text = "";
    menuCategoryController.text = "bottle";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Add / Edit Restaurant'))),
      body: Column(
        children: [
          Card(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextField(
                          label: "Name",
                          controller: nameController,
                          func: () {},
                        ),
                        MyTextField(
                            label: "Number",
                            controller: numberController,
                            func: () {}),
                        MyTextField(
                            label: "Username",
                            controller: userNameController,
                            func: () {}),
                        MyTextField(
                            label: "Password",
                            controller: passwordController,
                            func: () {}),
                      ],
                    ),
                  ),
          ),
          if (!isLoading)
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  String message = await addRestaurant(
                      nameController.text.trim(),
                      numberController.text.trim(),
                      userNameController.text.trim(),
                      passwordController.text.trim());
                  showToast(context, message);

                  resetControllers();
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('Add Restaurant'),
              ),
            ),
          Expanded(
            flex: 2,
            child: Card(
              child: StreamBuilder(
                stream: firestore.collection('restaurants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final restaurants = snapshot.data!.docs;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: ListView.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        final docId = restaurant.id;
                        final name = restaurant['name'];
                        final number = restaurant['number'];
                        final username = restaurant['username'];
                        final password = restaurant['password'];
                        final menu = restaurant['menu'] as List<dynamic>;

                        return Container(
                          color:
                              index % 2 == 0 ? Colors.grey[800] : Colors.black,
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text('Number: $number'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteRestaurant(docId),
                            ),
                            onTap: () {
                              nameController.text = name;
                              numberController.text = number;
                              userNameController.text = username;
                              passwordController.text = password;

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Restaurant'),
                                  content: isLoading
                                      ? CircularProgressIndicator()
                                      : SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              MyTextField(
                                                  label: 'Name',
                                                  controller: nameController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'Number',
                                                  controller: numberController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'Username',
                                                  controller:
                                                      userNameController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'Password',
                                                  controller:
                                                      passwordController,
                                                  func: () {}),
                                              SizedBox(height: 10),
                                              MyTextField(
                                                  label: 'New Menu Item',
                                                  controller:
                                                      menuItemController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'New Menu Price',
                                                  inputType:
                                                      TextInputType.number,
                                                  controller:
                                                      menuPriceController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'New Menu Description',
                                                  controller:
                                                      menuDescriptionController,
                                                  func: () {}),
                                              MyTextField(
                                                  label: 'New Menu Category',
                                                  controller:
                                                      menuCategoryController,
                                                  func: () {}),
                                              Text('Menu'),
                                              for (int i = 0;
                                                  i < menu.length;
                                                  i++)
                                                ListTile(
                                                  title: Text(menu[i]['item']),
                                                  subtitle: Text(
                                                      'Price: ${menu[i]['price']}'),
                                                  trailing: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      deleteMenuItem(
                                                        docId,
                                                        menu[i]['item'],
                                                        menu[i]['price'],
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        nameController.text = name;
                                        numberController.text = number;
                                        userNameController.text = username;
                                        passwordController.text = password;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        String message = await editRestaurant(
                                            docId,
                                            nameController.text.trim(),
                                            numberController.text.trim(),
                                            userNameController.text.trim(),
                                            passwordController.text.trim(),
                                            "");
                                        showToast(context, message);

                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        String itemPrice = (double.tryParse(
                                                    menuPriceController.text))
                                                .toString() ??
                                            "0.0";
                                        addMenuItem(
                                            docId,
                                            menuItemController.text.trim(),
                                            itemPrice,
                                            menuDescriptionController.text
                                                .trim(),
                                            menuCategoryController.text
                                                .toLowerCase()
                                                .contains("bottle"));

                                        menuItemController.clear();
                                        menuPriceController.clear();
                                        menuDescriptionController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Add Menu Item'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
