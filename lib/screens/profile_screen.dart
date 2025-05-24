// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_stats.dart';
import '../widgets/settings_menu.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileHeader(),
            SizedBox(height: 20),
            ProfileInfo(),
            SizedBox(height: 20),
            ProfileStats(),
            SizedBox(height: 20),
            SettingsMenu(),
          ],
        ),
      ),
    );
  }
}
