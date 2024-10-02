import 'package:flutter/material.dart';

typedef OnChange = void Function(String)?;

class MyTextFormFieldW extends StatelessWidget {
  final String hint;

  final TextEditingController textEditingController;

  static final _grayColor = Colors.grey.shade700;

  final bool obscureText;

  final ValueChanged<String>? onChanged;

  const MyTextFormFieldW(
      {super.key,
      required this.hint,
      required this.textEditingController,
      this.onChanged,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        obscureText: obscureText,
        controller: textEditingController,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter your $hint';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w400, color: _grayColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: _grayColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _grayColor),
          ),
        ),
      ),
    );
  }
}