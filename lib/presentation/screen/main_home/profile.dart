import 'package:flutter/material.dart';
import 'package:notesapp/models/profile_model.dart';
import 'package:notesapp/presentation/screen/main_home/edit_bioprofile.dart';

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
      name: 'Susan Jong',
      email: 'susanjong5@gmail.com',
      bio: 'Smile in front of your assignments',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background to white
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
          onTap: () => _showLogoutDialog(context),
        ),
        SettingItem(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently remove your account data',
          iconColor: const Color(0xFFFF6B6B),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildButton(String label) {
    return Container(
      width: 88.81,
      height: 24,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 88.81,
              height: 24,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() {}

  void _navigateToHelpFAQ() {}

  void _navigateToAbout() {}

  void _navigateToResetPassword() {}

  // Dialog methods
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFFF6B6B))),
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
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
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
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
                ),
              ],
            ),
          ),
        const SizedBox(width: 12),
        IconButton(
            icon: const Icon(Icons.edit_outlined),
            splashRadius: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditAccountInformationScreen()),
              );
            }
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
            SizedBox(
              width: 35,
              height: 35,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: const ShapeDecoration(
                      color: Color(0x7FC4C4C4),
                      shape: OvalBorder(),
                    ),
                  ),
                  Icon(
                    item.icon,
                    color: item.iconColor ?? const Color(0xFF1A1A1A),
                    size: 20,
                  ),
                ],
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
