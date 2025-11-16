import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_bio_box.dart';
import 'package:twithub/components/my_follow_button.dart';
import 'package:twithub/components/my_input_alert_box.dart';
import 'package:twithub/components/my_post_tile.dart';
import 'package:twithub/components/my_profile_stats.dart';
import 'package:twithub/helper/navigate_screen.dart';
import 'package:twithub/models/user.dart';
import 'package:twithub/provider/database_provider.dart';
import 'package:twithub/services/auth/auth_services.dart';

import 'following_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //provider
  late final listeningProvide = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //user info
  UserProfile? user;
  final currentUserId = AuthService().getCurrentUid();
  bool _isLoading = true;
  bool _isFollowing = false;

  //text controller for bio
  final bioController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    //get user profile info
    user = await databaseProvider.userProfile(widget.uid);

    //load followers & following for this user
    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);

    //update following state
    _isFollowing = databaseProvider.isFollowing(widget.uid);

    setState(() {
      _isLoading = false;
    });
  }

  //show edit bio box
  void _showEditBioBOx() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: bioController,
        hintText: "Edit Bio",
        onPressed: saveBio,
        onPressedText: "Save",
      ),
    );
  }

  //save update bio
  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });

    //update bio
    await databaseProvider.updateBio(bioController.text);

    await loadUser();

    setState(() {
      _isLoading = false;
    });
  }

  // toggle follow
  Future<void> toggleFollow() async {
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unfollow'),
          content: Text('Are you sure want to unfollow this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await databaseProvider.unFollowUser(widget.uid);
              },
              child: Text('Unfollow'),
            ),
          ],
        ),
      );
    } else {
      await databaseProvider.followUser(widget.uid);
    }

    //update isFollowing state
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    //get user post
    final allUserPost = listeningProvide.filterUserPost(widget.uid);

    //list to follow & following count
    final followerCount = listeningProvide.getFollowerCount(widget.uid);
    final followingCount = listeningProvide.getFollowingCount(widget.uid);

    //list to is following
    _isFollowing = listeningProvide.isFollowing(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _isLoading ? '' : user!.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => goHomePage(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              _isLoading ? '' : '@${user!.username}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 25),
          MyProfileStats(
            postCount: allUserPost.length,
            followerCount: followerCount,
            followingCount: followingCount,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowingScreen(uid: widget.uid),
              ),
            ),
          ),
          if (user != null && user!.uid != currentUserId)
            MyFollowButton(onPressed: toggleFollow, isFollowing: _isFollowing),
          SizedBox(height: 25),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (user != null && user!.uid == currentUserId)
                  GestureDetector(
                    onTap: _showEditBioBOx,
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 5),
          // bio box
          MyBioBox(text: _isLoading ? '...' : user!.bio),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Post',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          // list of Post from user
          allUserPost.isEmpty
              ? Center(child: Text("No post..."))
              : ListView.builder(
                  itemCount: allUserPost.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final post = allUserPost[index];
                    return MyPostTile(
                      post: post,
                      onTapPost: () => goPostPage(context, post),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
