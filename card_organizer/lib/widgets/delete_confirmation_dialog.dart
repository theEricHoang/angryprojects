import 'package:flutter/material.dart';

/// Shows a non-dismissible delete confirmation dialog.
///
/// [itemName] – display name of the item being deleted (e.g. "Hearts folder").
/// [cascade]  – if true, warns the user that child cards will also be deleted.
///
/// Returns `true` if the user confirmed, `false` / `null` otherwise.
Future<bool?> showDeleteConfirmationDialog(
  BuildContext context, {
  required String itemName,
  bool cascade = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // non-dismissible for safety
    builder: (context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "$itemName"?'),
            if (cascade) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will permanently delete this folder and ALL cards inside it. This action cannot be undone.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
