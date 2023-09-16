import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

void showInputError(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Please provide valid input.'),
    duration: Duration(seconds: 2), // Adjust the duration as needed
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget NoNetworkDialog(func) {
  return Container(
    alignment: Alignment.center,
    child: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "There was an issue with network connectivity.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(onPressed: func, child: Text("Retry")),
          ],
        ),
      ),
    ),
  );
}

Future<bool> checkConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    return false;
  } else {
    // Connected to the internet
    return true;
  }
}

void showToast(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message), // Wrap the message in a Text widget
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  // Use Future.delayed to control the duration of the snackbar
  Future.delayed(Duration(seconds: 2), () {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  });
}

void showNetworkError(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Please Check your Connectivity'),
    duration: Duration(seconds: 2), // Adjust the duration as needed
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
