import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/models/comment.dart';
import 'package:twithub/provider/database_provider.dart';

import '../services/auth/auth_services.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onTapUser;

  const MyCommentTile({super.key, required this.comment, this.onTapUser});

  // show option for comment
  void _showOptions(BuildContext context) {
    String? currentUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnComment)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<DatabaseProvider>(
                      context,
                      listen: false,
                    ).deleteComment(comment.id, comment.postId);
                  },
                )
              else ...[
                ListTile(
                  //report post button
                  leading: Icon(Icons.flag),
                  title: Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                //block user button
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapUser,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 5),
                Text(
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
