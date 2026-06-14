import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class NotificationItem {
  final String id;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      icon: Iconsax.discount_shape,
      title: 'Special Discount!',
      body: 'Get 20% off on your next order. Use coupon code WELCOME20.',
      time: '5 mins ago',
    ),
    NotificationItem(
      id: '2',
      icon: Iconsax.shop,
      title: 'New Branch Open!',
      body: 'We are now serving at Gulshan. Order now for fast delivery!',
      time: '2 hours ago',
    ),
    NotificationItem(
      id: '3',
      icon: Iconsax.wallet_check,
      title: 'Wallet Topped Up',
      body: 'Your wallet has been credited with AED 500.00 successfully.',
      time: '1 day ago',
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: const Text('Notifications', style: TextStyle(fontSize: 19)),
        actions: [
          if (_notifications.isNotEmpty) ...[
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Iconsax.trash, size: 20),
              onPressed: _clearAll,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_status,
              color: Color(0xFFFF5E00),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have no new notifications at the moment.',
            style: TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Iconsax.trash, color: Colors.white),
        ),
        onDismissed: (_) => _dismissNotification(item.id),
        child: Surface(
          padding: const EdgeInsets.all(16),
          color: item.isRead ? Colors.white : const Color(0xFFFFFDFB),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue/Orange circular highlight for unread
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFFFFF2EC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.isRead
                          ? const Color(0xFF7A7A7A)
                          : const Color(0xFFFF5E00),
                      size: 22,
                    ),
                  ),
                  if (!item.isRead)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5E00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0B0B0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A5A5A),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
