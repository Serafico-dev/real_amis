import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFieldRequired extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;

  const NumberFieldRequired({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obbligatorio';
        }
        final n = int.tryParse(value.trim());
        if (n == null || n < 0) return 'Inserisci un numero valido';
        return null;
      },
    );
  }
}
