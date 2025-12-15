import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/home/data/models/notification_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import '../../../../config/routes/routes.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<bool>(
                stream: _notificationService.getNotificationSettingStream(),
                builder: (context, settingSnapshot) {
                  if (settingSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final isNotificationEnabled = settingSnapshot.data ?? true;

                  if (!isNotificationEnabled) {
                    return _buildDisabledState();
                  }

                  return StreamBuilder<List<NotificationModel>>(
                    stream: _notificationService.getNotificationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading notifications',
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }

                      final notifications = snapshot.data ?? [];

                      if (notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          // ✅ Delete All Button
                          if (notifications.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showDeleteAllDialog(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFFF6B6B),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_sweep,
                                            size: 18,
                                            color: Color(0xFFFF6B6B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Delete All',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: const Color(0xFFFF6B6B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return _buildNotificationCard(notification);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog konfirmasi Delete All
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete All Notifications?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'This action cannot be undone. All notifications will be permanently deleted.',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B6B6B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: const Color(0xFF6B6B6B)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await _notificationService.deleteAllNotifications();

                navigator.pop(); // Close dialog

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'All notifications deleted',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete notifications',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete All',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 29,
                  height: 29,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: OvalBorder(),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: _notificationService.getNotificationSettingStream(),
                      builder: (context, settingSnapshot) {
                        final isEnabled = settingSnapshot.data ?? true;

                        if (!isEnabled) {
                          return Text(
                            'Disabled',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFFF6B6B),
                            ),
                          );
                        }

                        return StreamBuilder<int>(
                          stream: _notificationService.getUnreadCountStream(),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            return Text(
                              unreadCount > 0 ? '$unreadCount unread' : 'All read',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                stream: _notificationService.getNotificationSettingStream(),
                builder: (context, settingSnapshot) {
                  final isEnabled = settingSnapshot.data ?? true;

                  if (!isEnabled) return const SizedBox();

                  return StreamBuilder<int>(
                    stream: _notificationService.getUnreadCountStream(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      if (unreadCount == 0) return const SizedBox();

                      return GestureDetector(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);

                          await _notificationService.markAllAsRead();

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'All notifications marked as read',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'Mark All Read',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0x9B999191),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

        final iconSize = isSmallScreen ? 100.0 : isMediumScreen ? 110.0 : 120.0;
        final innerIconSize = isSmallScreen ? 70.0 : isMediumScreen ? 80.0 : 90.0;
        final iconInnerSize = isSmallScreen ? 40.0 : isMediumScreen ? 45.0 : 50.0;
        final titleSize = isSmallScreen ? 20.0 : isMediumScreen ? 22.0 : 24.0;
        final descSize = isSmallScreen ? 12.0 : isMediumScreen ? 13.0 : 14.0;
        final buttonHeight = isSmallScreen ? 60.0 : isMediumScreen ? 56.0 : 60.0;
        final buttonTextSize = isSmallScreen ? 14.0 : isMediumScreen ? 15.0 : 16.0;
        final maxContentWidth = isSmallScreen ? screenWidth * 0.85 : isMediumScreen ? 320.0 : 360.0;

        return Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
                minHeight: screenHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 28,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value *
                                (1 - _animationController.value) * 2,
                            child: Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red.withValues(alpha: 0.2),
                                    Colors.red.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: innerIconSize,
                                  height: innerIconSize,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.red.shade600,
                                        Colors.red.shade400,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_off_outlined,
                                    size: iconInnerSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 28),

                    Text(
                      'Notifications are Off',
                      style: GoogleFonts.poppins(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),

                    Text(
                      'You won\'t receive any notifications until you enable them in settings',
                      style: GoogleFonts.poppins(
                        fontSize: descSize,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6B6B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 28 : 32),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      child: Container(
                        width: double.infinity,
                        height: buttonHeight,
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? 280 : isMediumScreen ? 300 : 320,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD732A8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD732A8).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: buttonTextSize + 6,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 10),
                            Text(
                              'Go to Settings',
                              style: GoogleFonts.poppins(
                                fontSize: buttonTextSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 14),

                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? 280 : isMediumScreen ? 300 : 320,
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD54F),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFFBAE38),
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Expanded(
                            child: Text(
                              'Enable notifications to stay updated on your tasks and reminders',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: const Color(0xFFFBAE38),
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    Color backgroundColor;
    Color borderColor;
    IconData iconData;
    Color iconColor;

    bool isOverdueCompletion = notification.type == 'achievement' &&
        notification.priority == 'high' &&
        notification.title.contains('Overdue');

    // ✅ Handle event notifications
    if (notification.type == 'event_reminder' || notification.type == 'event_created') {
      backgroundColor = const Color(0xFFF3E5F5);
      borderColor = const Color(0xFFD732A8);
      iconData = notification.type == 'event_reminder'
          ? Icons.event_available
          : Icons.event_note;
      iconColor = const Color(0xFFD732A8);
    } else if (isOverdueCompletion) {
      backgroundColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFC2DCFF);
      iconData = Icons.celebration;
      iconColor = const Color(0xFFD4183D);
    } else {
      switch (notification.type) {
        case 'achievement':
          backgroundColor = const Color(0xFFEFF6FF);
          borderColor = const Color(0xFFC2DCFF);
          iconData = Icons.celebration;
          iconColor = const Color(0xFF4CAF50);
          break;
        case 'deadline':
          backgroundColor = const Color(0xFFEFF6FF);
          borderColor = const Color(0xFFC2DCFF);
          iconData = Icons.access_time;
          iconColor = const Color(0xFFFF9800);
          break;
        case 'overdue':
          backgroundColor = const Color(0xFFFFEBEE);
          borderColor = const Color(0xFFFFCDD2);
          iconData = Icons.warning_amber_rounded;
          iconColor = const Color(0xFFD4183D);
          break;
        case 'reminder':
          backgroundColor = Colors.white;
          borderColor = const Color(0xFFC2DCFF);
          iconData = Icons.notifications_active;
          iconColor = const Color(0xFF2B7FFF);
          break;
        default:
          backgroundColor = Colors.white;
          borderColor = const Color(0xFFC2DCFF);
          iconData = Icons.info_outline;
          iconColor = const Color(0xFF6B6B6B);
      }
    }

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await _notificationService.markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: notification.isRead ? Colors.white : backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Icon(
                iconData,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF2B7FFF),
                            shape: OvalBorder(),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _formatTimestamp(notification.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (notification.type == 'overdue')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD4183D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (notification.type == 'deadline' && notification.relatedTaskId != null)
                        GestureDetector(
                          onTap: () => _handleReminder(notification),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFC4C4C4),
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Reminder',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see updates here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  Future<void> _handleReminder(NotificationModel notification) async {
    if (notification.relatedTaskId == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await _notificationService.scheduleReminder(
        taskId: notification.relatedTaskId!,
        taskTitle: notification.description.replaceAll('"', ''),
        reminderTime: DateTime.now().add(const Duration(hours: 1)),
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set successfully! ⏰',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to set reminder: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}