import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/campaign_model.dart';
import '../../../models/message_model.dart';
import '../../../services/chat_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/app_colors.dart';
import 'package:intl/intl.dart';

class CampaignChatTab extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignChatTab({super.key, required this.campaign});

  @override
  State<CampaignChatTab> createState() => _CampaignChatTabState();
}

class _CampaignChatTabState extends State<CampaignChatTab> {
  final _messageCtrl = TextEditingController();
  final _chatService = ChatService();
  bool _isSending = false;

  void _sendMessage() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null || _messageCtrl.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final message = MessageModel(
        id: _chatService.generateId(),
        campaignId: widget.campaign.id,
        senderId: user.uid,
        senderName: user.name,
        text: _messageCtrl.text.trim(),
        isAdmin: user.isAdmin,
        timestamp: DateTime.now(),
      );

      await _chatService.sendMessage(message);
      _messageCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream: _chatService.streamCampaignMessages(widget.campaign.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Say hello! 👋', style: TextStyle(color: Colors.grey)),
                );
              }

              final messages = snapshot.data!;
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == user?.uid;
                  
                  return _buildMessageBubble(msg, isMe);
                },
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final canDelete = !msg.isDeleted && (isMe || (user?.isAdmin == true));

    return GestureDetector(
      onLongPress: canDelete ? () => _showDeleteDialog(msg) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: msg.isDeleted
              ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : isMe 
                ? AppColors.primary 
                : msg.isAdmin 
                    ? Colors.amber.shade100 
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe && !msg.isDeleted)
                Text(
                  msg.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: msg.isAdmin ? Colors.orange.shade800 : AppColors.primary,
                  ),
                ),
              if (!isMe && !msg.isDeleted) const SizedBox(height: 4),
              if (msg.isDeleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'This message was deleted',
                      style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  ],
                )
              else
                Text(
                  msg.text,
                  style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(msg.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: (isMe && !msg.isDeleted) ? Colors.white70 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(MessageModel msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Delete this message for everyone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatService.deleteMessage(msg.campaignId, msg.id);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: _isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
