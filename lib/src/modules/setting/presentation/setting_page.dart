import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_app/src/modules/app/app_router.dart';

import '../../../../generated/colors.gen.dart';
import 'widgets/action_dialogs.dart';
import 'widgets/settings_app_bar.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_section.dart';
import 'widgets/switch_settings_item.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _privateAccount = false;
  bool _locationServices = false;

  final ActionDialogs _actionDialogs = ActionDialogs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.backgroundLight,
      appBar: SettingsAppBar(
        onBackPressed: () => context.router.push(const ProfileRoute()),
      ),
      body: ListView(
        children: [
          // Account Settings
          SettingsSection(
            title: 'ACCOUNT',
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.user,
                title: 'Account Information',
                subtitle: 'Update your personal details',
                onTap: () {
                  // Navigate to account info page
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.lock,
                title: 'Privacy and Safety',
                subtitle: 'Manage your privacy settings',
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.bell,
                title: 'Notifications',
                subtitle: 'Control your notification preferences',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.eye,
                title: 'Block',
                subtitle: 'User blocked list',
                onTap: () {
                  // 👉 Mở trang block list
                  context.router.push(const BlockedUsersRoute());
                },
              ),
            ],
          ),

          // General Settings
          SettingsSection(
            title: 'GENERAL',
            children: [
              SwitchSettingsItem(
                icon: FontAwesomeIcons.moon,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              SwitchSettingsItem(
                icon: FontAwesomeIcons.bell,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SwitchSettingsItem(
                icon: FontAwesomeIcons.lock,
                title: 'Private Account',
                subtitle: 'Make your account private',
                value: _privateAccount,
                onChanged: (value) {
                  setState(() {
                    _privateAccount = value;
                  });
                },
              ),
              SwitchSettingsItem(
                icon: FontAwesomeIcons.locationDot,
                title: 'Location Services',
                subtitle: 'Use your location for features',
                value: _locationServices,
                onChanged: (value) {
                  setState(() {
                    _locationServices = value;
                  });
                },
              ),
            ],
          ),

          // Support & About
          SettingsSection(
            title: 'SUPPORT & ABOUT',
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.circleQuestion,
                title: 'Help Center',
                subtitle: 'Get help with using the app',
                onTap: () {
                  // Navigate to help center
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.shield,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.fileLines,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              SettingsItem(
                icon: FontAwesomeIcons.info,
                title: 'About',
                subtitle: 'Learn more about our app',
                onTap: () {
                  // Navigate to about page
                },
              ),
            ],
          ),

          // Actions
          SettingsSection(
            title: 'ACTIONS',
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.arrowRightFromBracket,
                title: 'Log Out',
                subtitle: 'Sign out of your account',
                onTap: () => _actionDialogs.showLogoutDialog(context),
                showArrow: false,
              ),
              SettingsItem(
                icon: FontAwesomeIcons.trash,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _actionDialogs.showDeleteAccountDialog(context),
                showArrow: false,
              ),
            ],
          ),

          // App Version
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Version 1.0.0',
          style: TextStyle(
            color: ColorName.textGray,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
