import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_management/Helpers/Helpers.dart';

Future<String> addRestaurant(
    String name, String number, String username, String password) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (await checkConnectivity() == false) return "Not connected to internet!";
  if (name.isNotEmpty &&
      number.isNotEmpty &&
      username.isNotEmpty &&
      password.isNotEmpty) {
    try {
      firestore.collection('restaurants').add({
        'name': name,
        'number': number,
        'username': username,
        'password': password,
        'active': false,
        'location': '',
        'key': '',
        'menu': [],
      });
    } catch (e) {
      return e.toString();
    }
    return "Restaurant added successfully!";
  } else {
    return "Please enter valid information!";
  }
}

void deleteRestaurant(String docId) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.collection('restaurants').doc(docId).delete();
}

Future<String> editRestaurant(String docId, String name, String number,
    String username, String password, String key) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  if (await checkConnectivity() == false) return "Not connected to internet!";
  if (name.isNotEmpty &&
      number.isNotEmpty &&
      username.isNotEmpty &&
      password.isNotEmpty) {
    try {
      firestore.collection('restaurants').doc(docId).update({
        'name': name,
        'number': number,
        'username': username,
        'password': password,
        'key': key,
      });
    } catch (e) {
      return e.toString();
    }
    return "Restaurant edited successfully!";
  } else {
    return "Please enter valid information!";
  }
}

Future<String> deleteMenuItem(String docId, String name, String price) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  if (await checkConnectivity() == false) return "Not connected to internet!";
  try {
    firestore.collection('restaurants').doc(docId).update({
      'menu': FieldValue.arrayRemove([
        {'item': name, 'price': price},
      ]),
    });
  } catch (e) {
    return e.toString();
  }
  return "Menu item deleted successfully!";
}

Future<bool> addMenuItem(String docId, String menuItem, String menuPrice,
    String description, bool isBottle) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (menuItem.isNotEmpty && menuPrice.isNotEmpty) {
      final restaurantDoc = firestore.collection('restaurants').doc(docId);
      final menuSnapshot = await restaurantDoc.get();

      // Check if the item already exists in the menu
      final existingMenu = menuSnapshot.data()?['menu'] ?? [];
      final isDuplicate = existingMenu.any((item) => item['item'] == menuItem);

      if (!isDuplicate) {
        await restaurantDoc.update({
          'menu': FieldValue.arrayUnion([
            {
              'item': menuItem,
              'price': menuPrice,
              'description': description,
              'isBottle': isBottle,
            },
          ]),
        });
        // Return true only when the update is successful and not a duplicate
        return true;
      }
    }
    // Return false if menuItem or menuPrice is empty or if it's a duplicate
    return false;
  } catch (e) {
    // Handle any errors here, you can print or log them if needed
    print('Error adding menu item: $e');
    return false; // Return false if an error occurs
  }
}

Future<bool> addMenuItemsTEmporary(
    String docId, List<Map<dynamic, dynamic>> menuItems) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (menuItems.isNotEmpty) {
      final restaurantDoc = firestore.collection('restaurants').doc(docId);
      final menuSnapshot = await restaurantDoc.get();

      // Check if the items already exist in the menu
      final existingMenu = menuSnapshot.data()?['menu'] ?? [];
      final existingItems = existingMenu.map((item) => item['item']).toSet();
      final newItems =
          menuItems.where((item) => !existingItems.contains(item['item']));

      if (newItems.isNotEmpty) {
        final newMenuItems = newItems.map((item) {
          return {
            'item': item['item'],
            'price': item['price'],
            'description': item['description'] ?? '',
            'isBottle': item['isBottle'],
          };
        }).toList();

        await restaurantDoc.update({
          'menu': FieldValue.arrayUnion(newMenuItems),
        });

        // Return true only when the update is successful and there are new items
        return true;
      }
    }
    // Return false if the list is empty or all items are duplicates
    return false;
  } catch (e) {
    // Handle any errors here, you can print or log them if needed
    print('Error adding menu items: $e');
    return false; // Return false if an error occurs
  }
}
