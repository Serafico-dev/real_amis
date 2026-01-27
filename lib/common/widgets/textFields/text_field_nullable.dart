import 'package:flutter/material.dart';

class TextFieldNullable extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;

  const TextFieldNullable({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
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
    );
  }
}
