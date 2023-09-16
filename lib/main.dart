import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_management/AdminPanel/MainScreen.dart';

import 'API/firebaseApi.dart';
import 'API/firebase_options.dart';
import 'AdminPanel/Add/Edit Restaurant/AddRestaurant.dart';
import 'Helpers/Helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseApi().initNotifications();
  runApp(MyApp());
}

bool connected = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<FirebaseApp?> initializeFirebaseApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseApi().initNotifications();
      return Firebase.app();
    } catch (e) {
      showToast(context, 'Error initializing Firebase: $e');
      return null; // Return null in case of an error
    }
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    connected = await checkConnectivity();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp?>(
      future: initializeFirebaseApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final firebaseApp = snapshot.data;

          return MaterialApp(
            color: Colors.teal,
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
                shadowColor: Colors.blue,
                scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
                dialogTheme: const DialogTheme(backgroundColor: Colors.black),
                listTileTheme: const ListTileThemeData(
                    leadingAndTrailingTextStyle: TextStyle(color: Colors.blue),
                    titleTextStyle: TextStyle(color: Colors.blue),
                    textColor: Colors.blue,
                    iconColor: Colors.blue),
                cardTheme: CardTheme(
                  color: Colors.black,
                  elevation: 5,
                  shadowColor: Colors.blue,
                  margin: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        25.0), // Adjust the radius as needed
                  ),
                ),
                buttonTheme: ButtonThemeData(buttonColor: Colors.yellow[800]),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,

                    shadowColor: Colors.blue,
                    backgroundColor:
                        Colors.yellow[800], // Set the desired color here
                  ),
                ),
                dialogBackgroundColor: Colors.black,
                dropdownMenuTheme: DropdownMenuThemeData(
                  menuStyle: MenuStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      shadowColor: MaterialStateProperty.all(Colors.blue),
                      surfaceTintColor:
                          MaterialStateProperty.all(Colors.black)),
                  inputDecorationTheme: const InputDecorationTheme(
                    fillColor: Colors.amber,
                    focusColor: Colors.blue,
                  ),
                ),
                iconTheme: IconThemeData(color: Colors.white),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                ),
                appBarTheme: AppBarTheme(backgroundColor: Colors.yellow[800]),
                primaryColor: Colors.yellow[800],
                hintColor: Colors.yellow[800],
                datePickerTheme: DatePickerThemeData(
                  headerForegroundColor: Colors.black,
                  dayOverlayColor: MaterialStateProperty.all(Colors.black),

                  headerBackgroundColor: Colors.yellow[800],
                  dayForegroundColor: MaterialStateProperty.all(Colors.white),
                  todayBackgroundColor:
                      MaterialStateProperty.all(Colors.yellow[800]),
                  todayForegroundColor: MaterialStateProperty.all(Colors.black),
                  weekdayStyle: TextStyle(color: Colors.white), //////
                  backgroundColor: Colors.grey[800],
                  rangePickerHeaderHeadlineStyle: TextStyle(color: Colors.blue),
                  rangePickerHeaderHelpStyle: TextStyle(color: Colors.white),
                ),
                bottomAppBarTheme: BottomAppBarTheme(color: Colors.yellow[800]),
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    tertiary: Colors.amber,
                    secondary: Colors.yellow[800],
                    primary: Colors.yellow[900])),

            // home: LoginPage(),
            home: MainScreenAdmin(),
          );
        } else {
          return MaterialApp(
            theme: ThemeData(
                shadowColor: Colors.blue,
                scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
                dialogTheme: const DialogTheme(backgroundColor: Colors.black),
                listTileTheme: const ListTileThemeData(
                    leadingAndTrailingTextStyle: TextStyle(color: Colors.blue),
                    titleTextStyle: TextStyle(color: Colors.blue),
                    textColor: Colors.blue,
                    iconColor: Colors.blue),
                cardTheme: CardTheme(
                  color: Colors.black,
                  elevation: 5,
                  shadowColor: Colors.blue,
                  margin: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        25.0), // Adjust the radius as needed
                  ),
                ),
                buttonTheme: ButtonThemeData(buttonColor: Colors.yellow[800]),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,

                    shadowColor: Colors.blue,
                    backgroundColor:
                        Colors.yellow[800], // Set the desired color here
                  ),
                ),
                dialogBackgroundColor: Colors.black,
                dropdownMenuTheme: DropdownMenuThemeData(
                  menuStyle: MenuStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      shadowColor: MaterialStateProperty.all(Colors.blue),
                      surfaceTintColor:
                          MaterialStateProperty.all(Colors.black)),
                  inputDecorationTheme: const InputDecorationTheme(
                    fillColor: Colors.amber,
                    focusColor: Colors.blue,
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                ),
                appBarTheme: AppBarTheme(backgroundColor: Colors.yellow[800]),
                primaryColor: Colors.yellow[800],
                hintColor: Colors.yellow[800],
                datePickerTheme: DatePickerThemeData(
                  headerForegroundColor: Colors.black,
                  dayOverlayColor: MaterialStateProperty.all(Colors.black),

                  headerBackgroundColor: Colors.yellow[800],
                  dayForegroundColor: MaterialStateProperty.all(Colors.white),
                  todayBackgroundColor:
                      MaterialStateProperty.all(Colors.yellow[800]),
                  todayForegroundColor: MaterialStateProperty.all(Colors.black),
                  weekdayStyle: TextStyle(color: Colors.white), //////
                  backgroundColor: Colors.grey[800],
                  rangePickerHeaderHeadlineStyle: TextStyle(color: Colors.blue),
                  rangePickerHeaderHelpStyle: TextStyle(color: Colors.white),
                ),
                bottomAppBarTheme: BottomAppBarTheme(color: Colors.yellow[800]),
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    tertiary: Colors.amber,
                    secondary: Colors.yellow[800],
                    primary: Colors.yellow[900])),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
