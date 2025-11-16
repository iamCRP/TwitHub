import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_comment_tile.dart';
import 'package:twithub/components/my_post_tile.dart';
import 'package:twithub/helper/navigate_screen.dart';
import 'package:twithub/models/post.dart';

import '../provider/database_provider.dart';

class PostScreen extends StatefulWidget {
  final Post post;

  const PostScreen({super.key, required this.post});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //provider
  late final listeningProvide = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  @override
  Widget build(BuildContext context) {
    //listen to all; comment for this post
    final allComment = listeningProvide.getComments(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text('P O S T', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          MyPostTile(
            post: widget.post,
            onTapUser: () => goUserPage(context, widget.post.uid),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Comments',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          allComment.isEmpty
              ? Center(child: Text('No Comment yet..'))
              : ListView.builder(
                  itemCount: allComment.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comment = allComment[index];
                    return MyCommentTile(
                      comment: comment,
                      onTapUser: () => goUserPage(context, comment.uid),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
