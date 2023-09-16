import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function func;
  TextInputType inputType;

  MyTextField(
      {required this.label,
      required this.controller,
      required this.func,
      this.inputType = TextInputType.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        keyboardType: inputType,
        onChanged: (value) => func(value),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
