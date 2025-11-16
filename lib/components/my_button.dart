import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool isLoading;

  const MyButton({
    super.key,
    required this.text,
    this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
        ),
      ),
    );
  }
}
