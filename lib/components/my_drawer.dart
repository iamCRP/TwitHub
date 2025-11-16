import 'package:flutter/material.dart';
import 'package:twithub/components/my_drawer_tile.dart';
import 'package:twithub/screen/home_screen.dart';
import 'package:twithub/screen/profile_screen.dart';
import 'package:twithub/screen/search_screen.dart';
import 'package:twithub/screen/settings_screen.dart';

import '../services/auth/auth_services.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // create or get your service instance
    final authService = AuthService();

    // get current uid (nullable)
    final currentUid = authService.getCurrentUid();
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Icon(
                  Icons.telegram_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                thickness: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 10),
              MyDrawerTile(
                title: 'H O M E',
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              MyDrawerTile(
                title: 'P R O F I L E',
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  if (currentUid != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(uid: currentUid),
                      ),
                    );
                  } else {
                    // optional: show message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not logged in')),
                    );
                  }
                },
              ),
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
              ),
              MyDrawerTile(
                title: 'S E T T I N G',
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
              Spacer(),
              Divider(
                thickness: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 10),
              MyDrawerTile(
                title: 'L O G O U T',
                icon: Icons.logout_rounded,
                onTap: () async {
                  Navigator.pop(context);
                  await authService.logout();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Logged out')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
