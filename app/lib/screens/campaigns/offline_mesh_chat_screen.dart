import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class OfflineMeshChatScreen extends StatefulWidget {
  final String campaignId;
  const OfflineMeshChatScreen({super.key, required this.campaignId});

  @override
  State<OfflineMeshChatScreen> createState() => _OfflineMeshChatScreenState();
}

class _OfflineMeshChatScreenState extends State<OfflineMeshChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isOfflineMode = true; // Simulated Bluetooth Mesh mode
  bool _isScanning = false;
  
  final List<Map<String, dynamic>> _messages = [
    {
      'senderName': 'System',
      'text': 'Offline Mesh Network initialized via Bluetooth. Messages will route through nearby peers.',
      'isSystem': true,
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'status': 'synced',
    }
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    
    final user = context.read<AuthProvider>().user;
    
    setState(() {
      _messages.add({
        'senderName': user?.name ?? 'Volunteer',
        'text': _msgController.text.trim(),
        'isSystem': false,
        'isMe': true,
        'time': DateTime.now(),
        'status': _isOfflineMode ? 'queued_bluetooth' : 'sent_cloud',
      });
      _msgController.clear();
    });
    
    _scrollToBottom();
    
    if (_isOfflineMode) {
      // Simulate peer response
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _messages.add({
            'senderName': 'Nearby Peer (Ali)',
            'text': 'Received via BT Hop. We are safe at Sector 4.',
            'isSystem': false,
            'isMe': false,
            'time': DateTime.now(),
            'status': 'received_bluetooth',
          });
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleNetwork() {
    setState(() {
      _isOfflineMode = !_isOfflineMode;
      if (!_isOfflineMode) {
        // Simulating cloud sync
        for (var m in _messages) {
          if (m['status'] == 'queued_bluetooth') {
            m['status'] = 'sent_cloud';
          }
        }
        _messages.add({
          'senderName': 'System',
          'text': 'Internet restored. 4 messages synced to Firestore Cloud.',
          'isSystem': true,
          'time': DateTime.now(),
          'status': 'synced',
        });
      } else {
        _isScanning = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _isScanning = false;
            _messages.add({
              'senderName': 'System',
              'text': 'Found 3 nearby peers via WiFi Direct/Bluetooth.',
              'isSystem': true,
              'time': DateTime.now(),
              'status': 'synced',
            });
          });
          _scrollToBottom();
        });
      }
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Comms'),
            Row(
              children: [
                Icon(
                  _isOfflineMode ? Icons.bluetooth_connected : Icons.cloud_done,
                  size: 12,
                  color: _isOfflineMode ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOfflineMode ? 'Bluetooth Mesh Mode' : 'Cloud Connected',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            )
          ],
        ),
        actions: [
          Row(
            children: [
              Text(_isOfflineMode ? 'Offline' : 'Online', style: const TextStyle(fontSize: 12)),
              Switch(
                value: !_isOfflineMode,
                onChanged: (_) => _toggleNetwork(),
                activeColor: Colors.greenAccent,
                inactiveThumbColor: Colors.blueAccent,
                inactiveTrackColor: Colors.blue.withOpacity(0.5),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          if (_isScanning)
            Container(
              color: Colors.blue.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Scanning for nearby mesh nodes...'),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isSystem'] == true) {
                  return _buildSystemMessage(msg);
                }
                return _buildChatMessage(msg, isDark);
              },
            ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(Map<String, dynamic> msg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg['text'],
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> msg, bool isDark) {
    final isMe = msg['isMe'] == true;
    final status = msg['status'];
    
    IconData statusIcon = Icons.check;
    Color statusColor = Colors.grey;
    
    if (status == 'queued_bluetooth') {
      statusIcon = Icons.bluetooth;
      statusColor = Colors.blue;
    } else if (status == 'sent_cloud') {
      statusIcon = Icons.done_all;
      statusColor = Colors.green;
    } else if (status == 'received_bluetooth') {
      statusIcon = Icons.bluetooth_connected;
      statusColor = Colors.blueAccent;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(msg['senderName'], style: TextStyle(fontSize: 10, color: isDark ? AppColors.primaryLight : AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              msg['text'],
              style: TextStyle(color: isMe ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg['time'].hour}:${msg['time'].minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textSecondary),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(statusIcon, size: 12, color: isMe ? Colors.white70 : statusColor),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ]
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isOfflineMode ? Icons.bluetooth : Icons.attachment),
            color: _isOfflineMode ? Colors.blue : AppColors.textSecondary,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: _isOfflineMode ? 'Send via Bluetooth Mesh...' : 'Send message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isOfflineMode ? Colors.blue : AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
