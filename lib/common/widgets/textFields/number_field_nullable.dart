import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFieldNullable extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;

  const NumberFieldNullable({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
