import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showSuccessDialog(BuildContext context, String message,
    {VoidCallback? onContinue}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Access Restricted',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.red,
            ),
          ),
        ],
      ),
      content: const Text(
        'This app is not permitted in your region.',
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onContinue != null) onContinue();
          },
          child: const Text(
            'OK',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
