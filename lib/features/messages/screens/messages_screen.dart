import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/empty_states.dart';

/// Messages Screen
/// Secure messaging with providers and support circle
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Messages',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewMessage,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildMessagesList()),
        ],
      ),
    );

  Widget _buildFilterChips() {
    final filters = ['All', 'Unread', 'Providers', 'Support Circle'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (final context, final index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (final selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = _getFilteredMessages();

    if (messages.isEmpty) {
      return EmptyState(
        icon: Icons.message,
        title: 'No messages',
        description: 'Your conversations will appear here.',
        action: PrimaryButton(
          text: 'Start New Message',
          onPressed: _startNewMessage,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (final context, final index) {
        final message = messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(final Map<String, dynamic> message) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openConversation(message),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: message['isProvider']
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    child: Text(
                      message['name'].split(' ').map((final n) => n[0]).join(),
                      style: TextStyle(
                        color: message['isProvider']
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (message['isOnline'])
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: message['unreadCount'] > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          message['time'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message['lastMessage'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: message['unreadCount'] > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (message['unreadCount'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message['unreadCount'].toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (message['type'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: message['isProvider']
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['type'],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: message['isProvider']
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredMessages() {
    final allMessages = [
      {
        'name': 'Dr. Sarah Johnson',
        'lastMessage': 'Thank you for the session today! How are you feeling?',
        'time': '2 min ago',
        'unreadCount': 2,
        'isProvider': true,
        'isOnline': true,
        'type': 'Physiotherapist',
      },
      {
        'name': 'Mike Wilson',
        'lastMessage': 'Can we reschedule tomorrow\'s appointment?',
        'time': '1 hour ago',
        'unreadCount': 1,
        'isProvider': false,
        'isOnline': false,
        'type': 'Support Worker',
      },
      {
        'name': 'Emma Davis',
        'lastMessage': 'I have a question about my treatment plan',
        'time': '3 hours ago',
        'unreadCount': 0,
        'isProvider': true,
        'isOnline': false,
        'type': 'Occupational Therapist',
      },
      {
        'name': 'John Smith',
        'lastMessage': 'The new equipment arrived today',
        'time': '1 day ago',
        'unreadCount': 0,
        'isProvider': false,
        'isOnline': true,
        'type': 'Family Member',
      },
      {
        'name': 'ABC Physiotherapy',
        'lastMessage': 'Your next appointment is confirmed for Friday',
        'time': '2 days ago',
        'unreadCount': 0,
        'isProvider': true,
        'isOnline': false,
        'type': 'Service Provider',
      },
    ];

    switch (_selectedFilter) {
      case 'Unread':
        return allMessages
            .where((final msg) => (msg['unreadCount'] as int) > 0)
            .toList();
      case 'Providers':
        return allMessages.where((final msg) => msg['isProvider'] as bool).toList();
      case 'Support Circle':
        return allMessages
            .where((final msg) => !(msg['isProvider'] as bool))
            .toList();
      default:
        return allMessages;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Search Messages'),
        content: const Text('Message search feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Filter Messages'),
        content: const Text('Advanced filtering options coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startNewMessage() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('New Message'),
        content: const Text('Start a new conversation feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openConversation(final Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text('Conversation with ${message['name']}'),
        content: const Text('Chat interface coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
