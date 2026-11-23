import 'package:flutter/material.dart';

void showOwnerMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.right),
        behavior: SnackBarBehavior.floating,
      ),
    );
