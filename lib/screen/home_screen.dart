import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_drawer.dart';
import 'package:twithub/components/my_input_alert_box.dart';
import 'package:twithub/components/my_post_tile.dart';
import 'package:twithub/helper/navigate_screen.dart';
import 'package:twithub/models/post.dart';
import 'package:twithub/provider/database_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //provider
  late final listeningProvide = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //text controller
  final _messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAllPost();
  }

  //load all Post
  Future<void> loadAllPost() async {
    await databaseProvider.loadAllPosts();
  }

  //show post message dialog box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _messageController,
        hintText: "What's on your mind?",
        onPressed: () async {
          await postMessage(_messageController.text);
        },
        onPressedText: 'Post',
      ),
    );
  }

  //user post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.primary,
          title: Text('H O M E', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(text: 'For you'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _buildPostList(listeningProvide.allPosts),
            _buildPostList(listeningProvide.followingPosts),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? Center(child: Text('Nothing here..'))
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MyPostTile(
                post: post,
                onTapUser: () => goUserPage(context, post.uid),
                onTapPost: () => goPostPage(context, post),
              );
            },
          );
  }
}
