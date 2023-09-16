import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:restaurant_management/AdminPanel/Add/Edit%20Restaurant/AddRestaurant.dart';
import 'package:restaurant_management/AdminPanel/Analytics/Analytics.dart';
import 'package:restaurant_management/AdminPanel/Analytics/RestaurantsAnalysis.dart';
import 'package:restaurant_management/AdminPanel/Misc/misc.dart';
import 'package:restaurant_management/AdminPanel/Place%20Order/PlaceOrder.dart';
import 'package:restaurant_management/AdminPanel/View%20Orders/ViewOrders.dart';
import 'package:restaurant_management/Models/Restaurants.dart';

class MainScreenAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/Capture.png"),
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 20,
                shrinkWrap: true,
                mainAxisSpacing: 20,
                padding: EdgeInsets.all(20),
                children: [
                  CustomButton(
                    text: 'Add / Edit Restaurants',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddRestaurant()),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'View Analytics',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Analytics()),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'Place an Order',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlaceOrder()),
                      );
                      // Place an Order functionality
                    },
                  ),
                  CustomButton(
                    text: 'View Orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewOrders()),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTaxAndDeliveryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  CustomButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          text,
        ),
      ),
    );
  }
}
