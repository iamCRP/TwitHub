import 'package:flutter/material.dart';

/*

INPUT ALERT BOX

TO use this widget , you need:

- text controller
- hint text
- a function
- text button

 */

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.hintText,
    this.onPressed,
    required this.onPressedText,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: TextField(
        controller: textController,
        maxLength: 140,
        maxLines: 3,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          fillColor: Theme.of(context).colorScheme.secondary,
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed!();
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}
