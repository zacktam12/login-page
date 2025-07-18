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
      title: const Text(
        'Success!',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onContinue != null) onContinue();
          },
          child: const Text(
            'CONTINUE',
            style: TextStyle(
              color: Color(0xFF1877F2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
