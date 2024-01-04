import 'package:flutter/material.dart';

class SnackBarPopUp {
  static void callSnackBar(String message, context, color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )
        ),
      ),
      elevation: 10,
      margin: const EdgeInsets.all(10),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
    ));
  }
}
