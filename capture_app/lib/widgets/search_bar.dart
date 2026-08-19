import 'package:flutter/material.dart';
import '../config/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;

  const SearchBarWidget({
    required this.onChanged,
    this.hintText = 'Search...',
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: kTextSecondary),
        prefixIcon: Icon(Icons.search, color: kTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusL),
          borderSide: BorderSide(color: kBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusL),
          borderSide: BorderSide(color: kBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusL),
          borderSide: BorderSide(color: kAccentOrange, width: 2),
        ),
      ),
      style: TextStyle(color: kTextPrimary),
    );
  }
}
