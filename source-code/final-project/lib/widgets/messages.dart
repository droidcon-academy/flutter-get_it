import 'package:flutter/material.dart';

void showSnackbarMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}
