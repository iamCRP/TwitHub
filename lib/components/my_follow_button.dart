import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          padding: EdgeInsets.all(18),
          onPressed: onPressed,
          color: isFollowing
              ? Theme.of(context).colorScheme.primary
              : Colors.blue,
          child: Text(
            isFollowing ? 'UnFollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
