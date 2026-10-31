
import 'package:flutter/material.dart';

class UserFeedback {
  UserFeedback._();

  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green.shade700,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blueGrey.shade700,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    if (!context.mounted || message.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    bool destructive = false,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
