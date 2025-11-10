import 'package:flutter/material.dart';
import 'package:notesapp/models/profile_model.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({Key? key}) : super(key: key);

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool _notificationsEnabled = true;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
  }

  void _initializeUserProfile() {
    _userProfile = UserProfile(
      // TODO: Replace with actual user profile data and get the user data from db
      name: 'Susan Jong',
      email: 'susanjong5@gmail.com',
      bio: 'Smile in front of your assignments',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileCard(
                profile: _userProfile,
                onEdit: _navigateToEditProfile,
              ),
              const SizedBox(height: 24),
              _buildPreferenceSection(),
              const SizedBox(height: 24),
              _buildSupportSection(),
              const SizedBox(height: 24),
              _buildSecuritySection(),
              const SizedBox(height: 24),
              _buildDangerZoneSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Account Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPreferenceSection() {
    return _SettingSection(
      title: 'PREFERENCE',
      items: [
        SettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive push notifications for reminders and updates',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeColor: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _SettingSection(
      title: 'SUPPORT',
      items: [
        SettingItem(
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          subtitle: 'Get answers to common questions',
          trailing: _buildButton('View'),
          onTap: _navigateToHelpFAQ,
        ),
        SettingItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          trailing: _buildButton('Info'),
          onTap: _navigateToAbout,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _SettingSection(
      title: 'SECURITY',
      items: [
        SettingItem(
          icon: Icons.lock_outline,
          title: 'Reset Password',
          subtitle: 'Change your account password',
          onTap: _navigateToResetPassword,
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _SettingSection(
      title: 'DANGER ZONE',
      items: [
        SettingItem(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          iconColor: const Color(0xFFFF6B6B),
          iconBackgroundColor: const Color(0xFFFFEBEE),
          onTap: () => _showLogoutDialog(context),
        ),
        SettingItem(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently remove your account data',
          iconColor: const Color(0xFFFF6B6B),
          iconBackgroundColor: const Color(0xFFFFEBEE),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() {
    // TODO: Change navigate to edit bio profile
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Placeholder(), // Ganti dengan EditProfilePage()
      ),
    ); */

  }

  void _navigateToHelpFAQ() {
    // TODO: Navigate to Help & FAQ page
  }

  void _navigateToAbout() {
    // TODO: Navigate to About page
  }

  void _navigateToResetPassword() {
    // TODO: Navigate to Reset Password page
  }

  // Dialog methods
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              Navigator.pop(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF6B6B),
          ),
        ),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete account logic
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Card Widget
class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(profile.imageUrl),
            backgroundColor: const Color(0xFFE0E0E0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B6B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Setting Section Widget
class _SettingSection extends StatelessWidget {
  final String title;
  final List<SettingItem> items;

  const _SettingSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFE0E0E0),
              indent: 60,
            ),
            itemBuilder: (context, index) {
              return _SettingItemWidget(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Setting Item Widget
class _SettingItemWidget extends StatelessWidget {
  final SettingItem item;

  const _SettingItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.iconBackgroundColor ?? const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor ?? const Color(0xFF1A1A1A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.iconColor ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 12),
              item.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}