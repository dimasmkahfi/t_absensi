import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsMenu({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Colors.blue[600],
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Settings & Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            'Change Password',
            Icons.lock_outline,
            () => _showChangePasswordDialog(context),
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuItem(
            'Notification Settings',
            Icons.notifications_outlined,
            () => _showNotificationSettings(context),
          ),
          Divider(height: 1, indent: 20, endIndent: 20),

          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuItem(
            'Help & Support',
            Icons.help_outline,
            () => _showHelpDialog(context),
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuItem(
            'About App',
            Icons.info_outline,
            () => _showAboutDialog(context),
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuItem('Logout', Icons.logout, onLogout, isLogout: true),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isLogout ? Colors.red : Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red[600] : Colors.blue[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red[600] : Colors.grey[800],
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Change Password'),
            content: Text('This feature will be available in a future update.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Notification Settings'),
            content: Text(
              'Notification preferences will be available in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Help & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need help? Contact us:'),
                SizedBox(height: 12),
                Text('📧 Email: support@company.com'),
                Text('📞 Phone: +62 21 1234 5678'),
                Text('🕒 Hours: Mon-Fri 9AM-5PM'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Attendance App',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.access_time,
        size: 48,
        color: Colors.blue[600],
      ),
      children: [
        Text('A modern attendance tracking application.'),
        SizedBox(height: 8),
        Text('Built with Flutter for seamless cross-platform experience.'),
      ],
    );
  }
}
