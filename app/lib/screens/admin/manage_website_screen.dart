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
      } else {
        _heroTitleCtrl.text = 'Radical Transparency';
        _heroSubtitleCtrl.text = 'Track every single dollar you donate through our live, public financial ledger.';
        _aboutCtrl.text = 'We are changing the way NGOs work by using absolute transparency.';
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
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Website content updated! Netlify will show changes instantly.')));
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
