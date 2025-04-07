import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isSuccess = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade800 : Colors.blue.shade800,
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
    ),
  );
}