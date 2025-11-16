import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/database_provider.dart';

class BlockedUserScreen extends StatefulWidget {
  const BlockedUserScreen({super.key});

  @override
  State<BlockedUserScreen> createState() => _BlockedUserScreenState();
}

class _BlockedUserScreenState extends State<BlockedUserScreen> {
  //provider
  late final listeningProvide = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //on start
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBlockedUser();
  }

  //load blocked users
  Future<void> loadBlockedUser() async {
    await databaseProvider.loadBlockedUser();
  }

  //show confirm unblock box
  void _showUnblockConfirmationBox(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unblock User'),
        content: Text('Are you sure want to Unblock this User?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await databaseProvider.unblockUser(userId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User Unblock!')));
            },
            child: Text('Unblock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //listen to blocked user
    final blockedUser = listeningProvide.blockedUsers;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'B L O C K   U S E R',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: blockedUser.isEmpty
          ? Center(child: Text('No blocked user..'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: blockedUser.length,
                itemBuilder: (context, index) {
                  final user = blockedUser[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      tileColor: Theme.of(context).colorScheme.secondary,
                      leading: Icon(Icons.person),
                      title: Text(user.name),
                      subtitle: Text('@${user.username}'),
                      trailing: IconButton(
                        onPressed: () => _showUnblockConfirmationBox(user.uid),
                        icon: Icon(Icons.block_flipped),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
