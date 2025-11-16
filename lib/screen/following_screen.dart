import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_user_tile.dart';
import 'package:twithub/models/user.dart';
import '../provider/database_provider.dart';

class FollowingScreen extends StatefulWidget {
  final String uid;

  const FollowingScreen({super.key, required this.uid});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late DatabaseProvider databaseProvider;

  @override
  void initState() {
    super.initState();
    // Delay provider access until after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    await databaseProvider.loadUserFollowersProfile(widget.uid);
    await databaseProvider.loadUserFollowingProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    // Get lists
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Connections",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(context, followers, 'No followers yet'),
            _buildUserList(context, following, 'No following yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<UserProfile> userList,
    String emptyMessage,
  ) {
    if (userList.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final user = userList[index];

        return MyUserTile(user: user);
      },
    );
  }
}
