import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/campaign_model.dart';
import '../../../models/message_model.dart';
import '../../../models/volunteer_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/volunteer_service.dart';
import '../../../services/cloudinary_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/app_colors.dart';

class CampaignChatTab extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignChatTab({super.key, required this.campaign});

  @override
  State<CampaignChatTab> createState() => _CampaignChatTabState();
}

class _CampaignChatTabState extends State<CampaignChatTab> {
  final _messageCtrl = TextEditingController();
  final _chatService = ChatService();
  final _picker = ImagePicker();

  bool _isSending = false;
  File? _selectedImage;

  // Mentions logic
  bool _showMentions = false;
  List<VolunteerModel> _allVolunteers = [];
  List<VolunteerModel> _filteredVolunteers = [];
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
    _messageCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageCtrl.removeListener(_onTextChanged);
    _messageCtrl.dispose();
    super.dispose();
  }

  void _loadVolunteers() async {
    final snapshot = await VolunteerService()
        .getVolunteersStream(widget.campaign.id)
        .first;
    if (mounted) {
      setState(() {
        _allVolunteers = snapshot;
      });
    }
  }

  void _onTextChanged() {
    final text = _messageCtrl.text;
    final selection = _messageCtrl.selection;

    if (selection.baseOffset == -1) return;

    final currentPos = selection.baseOffset;
    final textBeforeCursor = text.substring(0, currentPos);

    final lastAtSign = textBeforeCursor.lastIndexOf('@');

    if (lastAtSign != -1 &&
        (lastAtSign == 0 || textBeforeCursor[lastAtSign - 1] == ' ')) {
      final query = textBeforeCursor.substring(lastAtSign + 1).toLowerCase();
      if (!query.contains(' ')) {
        // Show mentions
        setState(() {
          _showMentions = true;
          _mentionStartIndex = lastAtSign;
          _filteredVolunteers = _allVolunteers
              .where((v) => v.userName.toLowerCase().contains(query))
              .toList();
        });
        return;
      }
    }

    if (_showMentions) {
      setState(() {
        _showMentions = false;
      });
    }
  }

  void _insertMention(VolunteerModel volunteer) {
    final text = _messageCtrl.text;
    final textBefore = text.substring(0, _mentionStartIndex);
    final textAfter = text.substring(_messageCtrl.selection.baseOffset);

    final mentionText = '@${volunteer.userName} ';

    _messageCtrl.text = '$textBefore$mentionText$textAfter';
    _messageCtrl.selection = TextSelection.collapsed(
      offset: textBefore.length + mentionText.length,
    );

    setState(() {
      _showMentions = false;
    });
  }

  List<String> _extractMentionedUserIds(String text) {
    List<String> mentionedIds = [];
    for (var volunteer in _allVolunteers) {
      if (text.contains('@${volunteer.userName}')) {
        mentionedIds.add(volunteer.userId);
      }
    }
    return mentionedIds;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _sendMessage() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null ||
        (_messageCtrl.text.trim().isEmpty && _selectedImage == null)) {
      return;
    }

    setState(() => _isSending = true);

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }

      final text = _messageCtrl.text.trim();
      final mentionedIds = _extractMentionedUserIds(text);

      final message = MessageModel(
        id: _chatService.generateId(),
        campaignId: widget.campaign.id,
        senderId: user.uid,
        senderName: user.name,
        text: text,
        isAdmin: user.isAdmin,
        timestamp: DateTime.now(),
        mentionedUserIds: mentionedIds,
        imageUrl: imageUrl,
      );

      await _chatService.sendMessage(message);
      _messageCtrl.clear();
      setState(() {
        _showMentions = false;
        _selectedImage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // WhatsApp-like background colors
    final bgColor = isDark ? const Color(0xFF0b141a) : const Color(0xFFefeae2);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<MessageModel>>(
                  stream: _chatService.streamCampaignMessages(
                    widget.campaign.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet. Say hello! 👋',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == user?.uid;

                        return _buildMessageBubble(msg, isMe, isDark);
                      },
                    );
                  },
                ),
                if (_showMentions && _filteredVolunteers.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredVolunteers.length,
                        itemBuilder: (context, index) {
                          final v = _filteredVolunteers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                v.userName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(v.userName),
                            onTap: () => _insertMention(v),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedImage != null) _buildImagePreview(),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => setState(() => _selectedImage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, bool isDark) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final canDelete = !msg.isDeleted && (isMe || (user?.isAdmin == true));

    // WhatsApp bubble colors
    final myBubbleColor = isDark
        ? const Color(0xFF005c4b)
        : const Color(0xFFd9fdd3);
    final otherBubbleColor = isDark
        ? const Color(0xFF202c33)
        : const Color(0xFFffffff);

    final textColor = isDark ? Colors.white : Colors.black87;
    final mentionColor = isDark ? Colors.lightBlueAccent : Colors.blue.shade700;

    return GestureDetector(
      onLongPress: canDelete ? () => _showDeleteDialog(msg) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4, top: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: EdgeInsets.only(
            left: msg.imageUrl != null ? 4 : 12,
            right: msg.imageUrl != null ? 4 : 12,
            top: msg.imageUrl != null ? 4 : 8,
            bottom: msg.imageUrl != null ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: msg.isDeleted
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                : (isMe ? myBubbleColor : otherBubbleColor),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe && !msg.isDeleted)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 2,
                    left: msg.imageUrl != null ? 8 : 0,
                  ),
                  child: Text(
                    msg.senderName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: msg.isAdmin
                          ? Colors.orange.shade800
                          : (isDark ? Colors.tealAccent : Colors.teal.shade700),
                    ),
                  ),
                ),
              if (msg.isDeleted)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'This message was deleted',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (msg.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: msg.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey.withValues(alpha: 0.2),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey.withValues(alpha: 0.2),
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  alignment: WrapAlignment.end,
                  children: [
                    if (msg.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          left: msg.imageUrl != null ? 8 : 0,
                          right: 8.0,
                          bottom: 2,
                        ),
                        child: _buildRichText(
                          msg.text,
                          textColor,
                          mentionColor,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: (msg.imageUrl != null && msg.text.isEmpty)
                            ? 8
                            : 0,
                        right: (msg.imageUrl != null && msg.text.isEmpty)
                            ? 4
                            : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(msg.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: isDark ? Colors.blueAccent : Colors.blue,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String text, Color defaultColor, Color mentionColor) {
    if (text.isEmpty) return Text('', style: TextStyle(color: defaultColor));

    List<TextSpan> spans = [];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('@') && word.length > 1) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(color: mentionColor, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(color: defaultColor),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.3),
        children: spans,
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
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 4),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2a3942) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: 5,
                      minLines: 1,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF00a884), // WhatsApp primary green
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
