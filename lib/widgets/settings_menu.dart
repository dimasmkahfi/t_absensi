// widgets/settings_menu.dart
import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem('Change Password', Icons.lock, () {}),
          Divider(height: 1),
          _buildMenuItem('Notification Settings', Icons.notifications, () {}),
          Divider(height: 1),
          _buildMenuItem('Help & Support', Icons.help, () {}),
          Divider(height: 1),
          _buildMenuItem('About', Icons.info, () {}),
          Divider(height: 1),
          _buildMenuItem('Logout', Icons.logout, () {}, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isLogout ? Colors.red : Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.blue[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.grey[800],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
