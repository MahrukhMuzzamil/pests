import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String labelText,
  IconData? prefixIcon,
  int? maxLines,
  int? minLines,
  bool obscureText = false,
  String? Function(String?)? validator,
  Widget? suffixIcon,
  void Function(String)? onChanged,
  void Function()? onTap,
  bool isReadOnly = false,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    keyboardType: keyboardType ?? TextInputType.text,
    onChanged: onChanged,
    onTap: onTap,
    minLines: minLines ?? 1,
    maxLines: maxLines ?? null,
    readOnly: isReadOnly,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(.2)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(.7)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
    ),
  );
}
