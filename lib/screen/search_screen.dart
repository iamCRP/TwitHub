import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_user_tile.dart';
import 'package:twithub/provider/database_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(
      context,
      listen: false,
    );
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users..',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              databaseProvider.searchUser(value);
            } else {
              databaseProvider.searchUser('');
            }
          },
        ),
      ),
      body: listeningProvider.searchResult.isEmpty
          ? Center(child: Text('No User Found..'))
          : ListView.builder(
              itemCount: listeningProvider.searchResult.length,
              itemBuilder: (context, index) {
                final user = listeningProvider.searchResult[index];
                return MyUserTile(user: user);
              },
            ),
    );
  }
}
