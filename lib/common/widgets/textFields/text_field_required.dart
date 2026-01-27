import 'package:flutter/material.dart';

class TextFieldRequired extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputType? keyboardType;

  const TextFieldRequired({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText è obbligatorio!';
        }
        return null;
      },
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}
