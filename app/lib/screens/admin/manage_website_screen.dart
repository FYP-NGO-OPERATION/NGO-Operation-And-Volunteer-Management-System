import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageWebsiteScreen extends StatefulWidget {
  const ManageWebsiteScreen({super.key});

  @override
  State<ManageWebsiteScreen> createState() => _ManageWebsiteScreenState();
}

class _ManageWebsiteScreenState extends State<ManageWebsiteScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _heroTitleCtrl = TextEditingController();
  final TextEditingController _heroSubtitleCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();
  
  // New Stats
  final TextEditingController _stat1Ctrl = TextEditingController();
  final TextEditingController _stat2Ctrl = TextEditingController();
  final TextEditingController _stat3Ctrl = TextEditingController();
  
  // New Footer Settings
  final TextEditingController _footerEmailCtrl = TextEditingController();
  final TextEditingController _footerPhoneCtrl = TextEditingController();
  final TextEditingController _footerAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('website_content').doc('settings').get();
      if (doc.exists) {
        final data = doc.data()!;
        _heroTitleCtrl.text = data['heroTitle'] ?? 'Radical Transparency';
        _heroSubtitleCtrl.text = data['heroSubtitle'] ?? 'Track every single dollar you donate through our live, public financial ledger.';
        _aboutCtrl.text = data['aboutText'] ?? 'We are changing the way NGOs work by using absolute transparency.';
        _stat1Ctrl.text = data['stat1'] ?? '100%';
        _stat2Ctrl.text = data['stat2'] ?? '50k+';
        _stat3Ctrl.text = data['stat3'] ?? '\$2.5M';
        _footerEmailCtrl.text = data['footerEmail'] ?? 'contact@hras-ngo.org';
        _footerPhoneCtrl.text = data['footerPhone'] ?? '+92 (300) 123-4567';
        _footerAddressCtrl.text = data['footerAddress'] ?? '123 Relief Street, Future City, PK';
      } else {
        _heroTitleCtrl.text = 'Radical Transparency';
        _heroSubtitleCtrl.text = 'Track every single dollar you donate through our live, public financial ledger.';
        _aboutCtrl.text = 'We are changing the way NGOs work by using absolute transparency.';
        _stat1Ctrl.text = '100%';
        _stat2Ctrl.text = '50k+';
        _stat3Ctrl.text = '\$2.5M';
        _footerEmailCtrl.text = 'contact@hras-ngo.org';
        _footerPhoneCtrl.text = '+92 (300) 123-4567';
        _footerAddressCtrl.text = '123 Relief Street, Future City, PK';
      }
    } catch (e) {
      debugPrint('Error loading website settings: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('website_content').doc('settings').set({
        'heroTitle': _heroTitleCtrl.text,
        'heroSubtitle': _heroSubtitleCtrl.text,
        'aboutText': _aboutCtrl.text,
        'stat1': _stat1Ctrl.text,
        'stat2': _stat2Ctrl.text,
        'stat3': _stat3Ctrl.text,
        'footerEmail': _footerEmailCtrl.text,
        'footerPhone': _footerPhoneCtrl.text,
        'footerAddress': _footerAddressCtrl.text,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Website content updated! Refresh the website to see changes.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _heroTitleCtrl.dispose();
    _heroSubtitleCtrl.dispose();
    _aboutCtrl.dispose();
    _stat1Ctrl.dispose();
    _stat2Ctrl.dispose();
    _stat3Ctrl.dispose();
    _footerEmailCtrl.dispose();
    _footerPhoneCtrl.dispose();
    _footerAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Website Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hero Section', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heroTitleCtrl,
                decoration: const InputDecoration(labelText: 'Hero Title', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heroSubtitleCtrl,
                decoration: const InputDecoration(labelText: 'Hero Subtitle', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              
              const Text('About Section', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutCtrl,
                decoration: const InputDecoration(labelText: 'About Us Text', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              const Text('Impact Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _stat1Ctrl, decoration: const InputDecoration(labelText: 'Stat 1 (e.g. 100%)', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _stat2Ctrl, decoration: const InputDecoration(labelText: 'Stat 2 (e.g. 50k+)', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _stat3Ctrl, decoration: const InputDecoration(labelText: 'Stat 3 (e.g. \$2.5M)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Footer Contact Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(controller: _footerEmailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _footerPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _footerAddressCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                  label: const Text('Save & Publish to Website'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
