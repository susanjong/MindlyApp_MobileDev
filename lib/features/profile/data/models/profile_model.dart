import 'package:flutter/material.dart';
class UserProfile {
  final String name;
  final String email;
  final String bio;
  final String imageUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    required this.imageUrl,
  });
}

class SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
    this.trailing,
  });
}