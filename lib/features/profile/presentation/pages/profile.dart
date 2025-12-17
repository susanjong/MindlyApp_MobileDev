import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../data/models/profile_model.dart';
import 'package:notesapp/features/profile/presentation/pages/edit_bioprofile.dart';
import 'dart:convert';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool? _notificationsEnabled;
  late UserProfile _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
    _loadUserDataFromFirestore();
    _loadNotificationSetting();
  }

  // load notification setting from firestore
  Future<void> _loadNotificationSetting() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          if (userData.containsKey('notificationsEnabled')) {
            _notificationsEnabled = userData['notificationsEnabled'] as bool;
          } else {
            _notificationsEnabled = true;
          }
        });
      } else if (mounted) {
        setState(() {
          _notificationsEnabled = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification setting: $e');
      if (mounted) {
        setState(() {
          _notificationsEnabled = true;
        });
      }
    }
  }

  // save notification setting to firestore
  Future<void> _saveNotificationSetting(bool value) async {
    try {
      await AuthService.updateUserData({
        'notificationsEnabled': value,
      });
    } catch (e) {
      debugPrint('Error saving notification setting: $e');
    }
  }

  void _initializeUserProfile() {
    _userProfile = UserProfile(
      name: 'User',
      email: 'user@example.com',
      bio: 'Update your bio here.',
      imageUrl: 'https://ui-avatars.com/api/?name=User&size=150&background=4CAF50&color=fff',
    );
  }

  Future<void> _loadUserDataFromFirestore() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final userData = await AuthService.getUserData();

      if (userData != null) {
        if (mounted) {
          setState(() {
            final displayName = userData['displayName'] ?? AuthService.getUserDisplayName() ?? 'User';
            final email = userData['email'] ?? AuthService.getCurrentUserEmail() ?? 'user@example.com';
            final bio = userData['bio'] ?? 'Update your bio here.';

            // Priority photoURL dari Firestore (support Base64 and removal)
            String imageUrl;
            final photoURL = userData['photoURL'];
            if (photoURL != null && photoURL.toString().isNotEmpty) {
              imageUrl = photoURL;
              debugPrint('Photo loaded from Firestore: ${photoURL.toString().substring(0, 50)}...');
            } else {
              imageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&size=150&background=4CAF50&color=fff';
              debugPrint('No photo in Firestore, using default avatar');
            }

            _userProfile = UserProfile(
              name: displayName,
              email: email,
              bio: bio,
              imageUrl: imageUrl,
            );

            _isLoadingProfile = false;
          });
        }
      } else {
        final displayName = AuthService.getUserDisplayName() ?? 'User';
        final email = AuthService.getCurrentUserEmail() ?? 'user@example.com';

        if (mounted) {
          setState(() {
            _userProfile = UserProfile(
              name: displayName,
              email: email,
              bio: 'Update your bio here.',
              imageUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&size=150&background=4CAF50&color=fff',
            );
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      final displayName = AuthService.getUserDisplayName() ?? 'User';
      final email = AuthService.getCurrentUserEmail() ?? 'user@example.com';

      if (mounted) {
        setState(() {
          _userProfile = UserProfile(
            name: displayName,
            email: email,
            bio: 'Update your bio here.',
            imageUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&size=150&background=4CAF50&color=fff',
          );
          _isLoadingProfile = false;
        });
      }
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserDataFromFirestore,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileCard(
                  profile: _userProfile,
                  isLoading: _isLoadingProfile,
                  onEdit: _navigateToEditProfile,
                  onRefresh: _loadUserDataFromFirestore,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      title: Text(
        'Account Profile',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
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
          trailing: _notificationsEnabled == null
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          )
              : Switch(
            value: _notificationsEnabled!,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveNotificationSetting(value);
            },
            activeThumbColor: const Color(0xFF4CAF50),
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
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.helpFaq);
          },
        ),
        SettingItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          trailing: _buildButton('Info'),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.aboutUs);
          },
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
          onTap: _showResetDialog,
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
          onTap: _showLogoutDialog,
        ),
        SettingItem(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently remove your account data',
          iconColor: const Color(0xFFFF6B6B),
          onTap: _showDeleteAccountDialog,
        ),
      ],
    );
  }

  Widget _buildButton(String label) {
    return Container(
      width: 88.81,
      height: 24,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF000000)),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.24,
          ),
        ),
      ),
    );
  }

  //  Navigate to edit profile and refresh data when back
  void _navigateToEditProfile() async {
    final navigator = Navigator.of(context);

    final result = await navigator.push(
      MaterialPageRoute(
        builder: (context) => const EditAccountInformationScreen(),
      ),
    );

    //  Refresh data after back from edit
    if (result == true && mounted) {
      debugPrint('Refreshing profile data after edit...');
      await _loadUserDataFromFirestore();
    }
  }

  void _showResetDialog() {
    if (!mounted) return;
    final dialogContext = context;

    showIOSDialog(
      context: dialogContext,
      title: 'Reset Password',
      message: 'Are you sure you want to \nreset your password ?',
      cancelText: 'Cancel',
      confirmText: 'Reset',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        final navigator = Navigator.of(dialogContext);

        navigator.pop();
        _showSuccessAndNavigate(
          title: 'Success !',
          message: 'You will be redirected to\n the password reset page.',
          routeName: AppRoutes.resetPassword,
          useReplacement: false,
        );
      },
    );
  }

  void _showLogoutDialog() {
    if (!mounted) return;
    final dialogContext = context;

    showIOSDialog(
      context: dialogContext,
      title: 'Logout',
      message: 'Are you sure you want to \nlogout this account?',
      cancelText: 'Cancel',
      confirmText: 'Logout',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        final navigator = Navigator.of(dialogContext);
        final messenger = ScaffoldMessenger.of(dialogContext);

        navigator.pop();

        try {
          await AuthService.signOut();

          if (mounted) {
            _showSuccessAndNavigate(
              title: 'Success !',
              message: 'Your account was\nsuccessfully logout.',
              routeName: AppRoutes.signIn,
              useReplacement: true,
            );
          }
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Logout failed: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showDeleteAccountDialog() {
    if (!mounted) return;
    final dialogContext = context;

    showIOSDialog(
      context: dialogContext,
      title: 'Delete Account',
      message: 'This action cannot be undone.\nAre you sure?',
      cancelText: 'Cancel',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        final navigator = Navigator.of(dialogContext);

        navigator.pop();

        _showSuccessAndNavigate(
          title: 'Success !',
          message: 'Your account has been\nsuccessfully deleted.',
          routeName: AppRoutes.signUp,
          useReplacement: true,
        );

        AuthService.deleteAccount().catchError((e) {
          debugPrint('Delete account error: $e');
        });
      },
    );
  }

  void _showSuccessAndNavigate({
    required String title,
    required String message,
    required String routeName,
    bool useReplacement = true,
  }) {
    if (!mounted) return;

    final parentContext = context;
    final navigator = Navigator.of(parentContext);

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final dialogNavigator = Navigator.of(dialogContext);

        Future.delayed(const Duration(seconds: 2), () {
          if (dialogNavigator.canPop()) {
            dialogNavigator.pop();

            Future.delayed(const Duration(milliseconds: 100), () {
              if (useReplacement) {
                navigator.pushReplacementNamed(routeName);
              } else {
                navigator.pushNamed(routeName);
              }
            });
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 317,
            padding: const EdgeInsets.all(24.0),
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Redirecting...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//  ProfileCard dengan Real-time Sync
class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;

  const _ProfileCard({
    required this.profile,
    required this.isLoading,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              _buildProfileImage(),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                    : Text(
                  profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                    : Text(
                  profile.email,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF3C527E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            splashRadius: 20,
            onPressed: () async {
              final navigator = Navigator.of(context);

              final result = await navigator.push(
                MaterialPageRoute(
                  builder: (context) => const EditAccountInformationScreen(),
                ),
              );

              //  Refresh after edit
              if (result == true && context.mounted) {
                debugPrint('🔄 Refreshing profile after edit from card...');
                onRefresh();
              }
            },
          ),
        ],
      ),
    );
  }

  //  Build profile image with Base64 support
  Widget _buildProfileImage() {
    // Check if it's Base64 data
    if (profile.imageUrl.startsWith('data:image')) {
      try {
        final base64String = profile.imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFFE0E0E0),
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Error displaying base64 image: $error');
                return _buildDefaultAvatar();
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint('❌ Error decoding base64 image: $e');
        return _buildDefaultAvatar();
      }
    }

    // Network image
    return CircleAvatar(
      radius: 32,
      backgroundImage: NetworkImage(profile.imageUrl),
      backgroundColor: const Color(0xFFE0E0E0),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('❌ Error loading network image: $exception');
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFF4CAF50),
      child: Text(
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

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
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFF999191),
              indent: 25,
              endIndent: 25,
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.iconColor ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
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

class SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });
}