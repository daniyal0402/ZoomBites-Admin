import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaxAndDeliveryScreen extends StatefulWidget {
  @override
  _EditTaxAndDeliveryScreenState createState() =>
      _EditTaxAndDeliveryScreenState();
}

class _EditTaxAndDeliveryScreenState extends State<EditTaxAndDeliveryScreen> {
  final TextEditingController taxController = TextEditingController();
  final TextEditingController bottleController = TextEditingController();
  final TextEditingController miscController = TextEditingController();
  final TextEditingController deliveryChargesController =
      TextEditingController();

  double? taxValue;
  double? deliveryChargesValue;
  double? miscValue;
  double? bottleValue;

  final CollectionReference miscCollection =
      FirebaseFirestore.instance.collection('misc');

  @override
  void initState() {
    super.initState();
    fetchMiscData();
  }

  Future<void> fetchMiscData() async {
    try {
      final DocumentSnapshot miscDoc =
          await miscCollection.doc('miscData').get();

      if (miscDoc.exists) {
        setState(() {
          taxValue = miscDoc['tax']?.toDouble();
          deliveryChargesValue = miscDoc['deliveryCharges']?.toDouble();
          miscValue = miscDoc['miscCharges']?.toDouble();
          bottleValue = miscDoc['bottleCharges']?.toDouble();
          taxController.text =
              taxController.text = taxValue?.toStringAsFixed(2) ?? '';
          deliveryChargesController.text =
              deliveryChargesValue?.toStringAsFixed(2) ?? '';
          miscController.text = miscValue?.toStringAsFixed(2) ?? '';
          bottleController.text = bottleValue?.toStringAsFixed(2) ?? '';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateMiscData() async {
    try {
      final double newTax = double.parse(taxController.text);
      final double newDeliveryCharges =
          double.parse(deliveryChargesController.text);
      final double newMisc = double.parse(miscController.text);
      final double newBottle = double.parse(bottleController.text);

      await miscCollection.doc('miscData').update({
        'tax': newTax,
        'deliveryCharges': newDeliveryCharges,
        'miscCharges': newMisc,
        'bottleCharges': newBottle,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data')),
      );
    }
  }

  @override
  void dispose() {
    taxController.dispose();
    deliveryChargesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Charges'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: taxController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Tax (%)'),
            ),
            TextFormField(
              controller: deliveryChargesController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Delivery Charges'),
            ),
            TextFormField(
              controller: miscController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Miscellaneous Charges'),
            ),
            TextFormField(
              controller: bottleController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Bottle Charges'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateMiscData();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
