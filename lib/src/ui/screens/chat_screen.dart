import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final String lastMessage;
  final String iconName;
  final IconData icon;
  final List<ChatMessage> messages;

  ChatChannel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.iconName,
    required this.icon,
    required this.messages,
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Active channel index for Owner
  int _selectedChannelIndex = 0;

  // Dummy data for customer support chat
  final List<ChatMessage> _customerMessages = [
    ChatMessage(
      sender: 'Support',
      text: 'Hello! Welcome to our support center. How can we help you today?',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      isMe: false,
    ),
    ChatMessage(
      sender: 'You',
      text: 'Hi, I wanted to ask if I can change the spice level of the Smash Burger I just ordered.',
      time: DateTime.now().subtract(const Duration(minutes: 7)),
      isMe: true,
    ),
    ChatMessage(
      sender: 'Support',
      text: 'Sure! I will notify the kitchen display team immediately to make it extra spicy for you.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
    ChatMessage(
      sender: 'You',
      text: 'Awesome, thank you so much for the quick response!',
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      isMe: true,
    ),
  ];

  // Dummy channels for Owner chat
  late final List<ChatChannel> _ownerChannels;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ownerChannels = [
      ChatChannel(
        id: 'kitchen',
        name: 'Kitchen Display team',
        lastMessage: 'Chef Ali: Potatoes are running low.',
        iconName: 'chef',
        icon: Iconsax.shop,
        messages: [
          ChatMessage(
            sender: 'Chef Ali',
            text: 'We are running low on fresh potatoes for the fries.',
            time: now.subtract(const Duration(minutes: 45)),
            isMe: false,
          ),
          ChatMessage(
            sender: 'You (Owner)',
            text: 'Acknowledged. I will place an inventory order right away.',
            time: now.subtract(const Duration(minutes: 40)),
            isMe: true,
          ),
          ChatMessage(
            sender: 'Chef Ali',
            text: 'Sounds good. Let me know when it is dispatched.',
            time: now.subtract(const Duration(minutes: 30)),
            isMe: false,
          ),
        ],
      ),
      ChatChannel(
        id: 'riders',
        name: 'Rider team chat',
        lastMessage: 'Hamza: Order #1085 delivered.',
        iconName: 'delivery',
        icon: Iconsax.truck_fast,
        messages: [
          ChatMessage(
            sender: 'Hamza R. (Rider)',
            text: 'I have picked up order #1085 and headed to the customer location.',
            time: now.subtract(const Duration(minutes: 25)),
            isMe: false,
          ),
          ChatMessage(
            sender: 'You (Owner)',
            text: 'Thanks Hamza. Drive safely!',
            time: now.subtract(const Duration(minutes: 22)),
            isMe: true,
          ),
          ChatMessage(
            sender: 'Hamza R. (Rider)',
            text: 'Order #1085 is delivered successfully to Asad.',
            time: now.subtract(const Duration(minutes: 10)),
            isMe: false,
          ),
        ],
      ),
      ChatChannel(
        id: 'support',
        name: 'Customer Service agents',
        lastMessage: 'Agent Sara: Query resolved.',
        iconName: 'support',
        icon: Iconsax.message_programming,
        messages: [
          ChatMessage(
            sender: 'Agent Sara',
            text: 'Customer requested a refund on a late order.',
            time: now.subtract(const Duration(minutes: 15)),
            isMe: false,
          ),
          ChatMessage(
            sender: 'You (Owner)',
            text: 'Process it if the delay was over 45 minutes.',
            time: now.subtract(const Duration(minutes: 12)),
            isMe: true,
          ),
          ChatMessage(
            sender: 'Agent Sara',
            text: 'Done. Customer notified and query marked as resolved.',
            time: now.subtract(const Duration(minutes: 5)),
            isMe: false,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final role = ref.read(userRoleProvider);
    final isCustomer = role == UserRole.customer;

    setState(() {
      if (isCustomer) {
        _customerMessages.add(
          ChatMessage(
            sender: 'You',
            text: text,
            time: DateTime.now(),
            isMe: true,
          ),
        );
      } else {
        _ownerChannels[_selectedChannelIndex].messages.add(
          ChatMessage(
            sender: 'You (Owner)',
            text: text,
            time: DateTime.now(),
            isMe: true,
          ),
        );
      }
    });

    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final isCustomer = role == UserRole.customer;
    final primaryColor = ref.watch(restaurantProvider).primaryColorHex;
    final themeColor = colorFromHex(primaryColor, fallback: AppColors.primary);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isCustomer
            ? _buildCustomerChatView(themeColor)
            : _buildOwnerChatView(themeColor, width),
      ),
    );
  }

  // CUSTOMER VIEW: Direct chat with support
  Widget _buildCustomerChatView(Color themeColor) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: themeColor.withValues(alpha: 0.1),
                radius: 20,
                child: Icon(Iconsax.message_favorite, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Support Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                        SizedBox(width: 4),
                        Text(
                          'Online Agents ready',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7A7A7A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _customerMessages.length,
            itemBuilder: (context, index) {
              final msg = _customerMessages[index];
              return _buildMessageBubble(msg, themeColor);
            },
          ),
        ),
        
        // Input Area
        _buildInputArea(themeColor),
      ],
    );
  }

  // OWNER VIEW: Split screen for desktop/wide viewport, tabs for mobile
  Widget _buildOwnerChatView(Color themeColor, double screenWidth) {
    final showSplitScreen = screenWidth >= 700;

    if (showSplitScreen) {
      return Row(
        children: [
          // Channels List
          SizedBox(
            width: 280,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      'Internal Chats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _ownerChannels.length,
                      itemBuilder: (context, index) {
                        return _buildChannelTile(index, themeColor);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Divider line
          Container(width: 0.5, color: AppColors.border),
          
          // Conversation Panel
          Expanded(
            child: _buildConversationPanel(themeColor),
          ),
        ],
      );
    } else {
      // Mobile View: Default to full conversations, tap back to see channel list if implemented
      // (For dummy ease, we show standard channel selection tabs at the top, then chat conversation below)
      return Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _ownerChannels.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedChannelIndex;
                final channel = _ownerChannels[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      channel.name.split(' ').first,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF7A7A7A),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: themeColor,
                    backgroundColor: const Color(0xFFF5F5F5),
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChannelIndex = index;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildConversationPanel(themeColor),
          ),
        ],
      );
    }
  }

  Widget _buildChannelTile(int index, Color themeColor) {
    final channel = _ownerChannels[index];
    final isSelected = index == _selectedChannelIndex;

    return Material(
      color: isSelected ? themeColor.withValues(alpha: 0.08) : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? themeColor : const Color(0xFFF5F5F5),
          radius: 18,
          child: Icon(
            channel.icon,
            color: isSelected ? Colors.white : const Color(0xFF7A7A7A),
            size: 16,
          ),
        ),
        title: Text(
          channel.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        subtitle: Text(
          channel.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A7A7A)),
        ),
        onTap: () {
          setState(() {
            _selectedChannelIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildConversationPanel(Color themeColor) {
    final channel = _ownerChannels[_selectedChannelIndex];

    return Column(
      children: [
        // Conversation Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: Colors.white,
          child: Row(
            children: [
              Icon(channel.icon, color: themeColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  channel.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: channel.messages.length,
            itemBuilder: (context, index) {
              final msg = channel.messages[index];
              return _buildMessageBubble(msg, themeColor);
            },
          ),
        ),
        
        // Input
        _buildInputArea(themeColor),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, Color themeColor) {
    final bubbleColor = msg.isMe ? themeColor : Colors.white;
    final textColor = msg.isMe ? Colors.white : const Color(0xFF1E1E1E);
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeStr = '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!msg.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
              child: Text(
                msg.sender,
                style: const TextStyle(fontSize: 10, color: Color(0xFF7A7A7A), fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0),
            child: Text(
              timeStr,
              style: const TextStyle(fontSize: 9, color: Color(0xFFB0B0B0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Iconsax.send_1, color: themeColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
