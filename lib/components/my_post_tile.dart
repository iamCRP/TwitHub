import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_input_alert_box.dart';
import 'package:twithub/models/post.dart';
import 'package:twithub/services/auth/auth_services.dart';

import '../helper/time_formatter.dart';
import '../provider/database_provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onTapUser;
  final void Function()? onTapPost;

  const MyPostTile({
    super.key,
    required this.post,
    this.onTapUser,
    this.onTapPost,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  //provider
  late final listeningProvide = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //on start
  @override
  void initState() {
    super.initState();
    //load comment
    _loadComments();
  }

  // user tapped like (or unlike)
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  //comment text controller
  final _commentController = TextEditingController();

  // user open comment box
  void _openCommentBox() async {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _commentController,
        hintText: 'Type a comment..',
        onPressedText: 'Comment',
        onPressed: () async {
          await _addComment();
        },
      ),
    );
  }

  //user tapped post to  add comment
  Future<void> _addComment() async {
    //does nothing if theres nothing in the textField
    if (_commentController.text.trim().isEmpty) return;

    //attempt to post comment
    try {
      await databaseProvider.addComment(
        widget.post.id,
        _commentController.text.trim(),
      );
    } catch (e) {
      print(e);
    }
  }

  //load comment
  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  // show option for post
  void _showOptions() {
    String? currentUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnPost)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () async {
                    Navigator.pop(context);
                    await databaseProvider.deletePost(widget.post.id);
                  },
                )
              else ...[
                ListTile(
                  //report post button
                  leading: Icon(Icons.flag),
                  title: Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                    _reportPostConfirmationBox();
                  },
                ),
                //block user button
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    _blockUserConfirmationBox();
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

  // report post confirmation
  void _reportPostConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Message'),
        content: Text('Are you sure want to report this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await databaseProvider.reportUser(
                widget.post.id,
                widget.post.uid,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Message reported!')));
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  // report post confirmation
  void _blockUserConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await databaseProvider.blockUser(widget.post.uid);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User Block!')));
            },
            child: Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //dose the current user like this post
    bool likedByCurrentUser = listeningProvide.isPostLikedByCurrentUser(
      widget.post.id,
    );

    //listen to like count
    int likeCount = listeningProvide.getLikeCount(widget.post.id);

    //listen to comment count
    int commentCount = listeningProvide.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onTapPost,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onTapUser,
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '@${widget.post.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => _showOptions(),
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
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // like section
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(
                                Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        likeCount != 0 ? likeCount.toString() : "",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // comment section
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        commentCount != 0 ? commentCount.toString() : "",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  formatTimestamp(widget.post.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
