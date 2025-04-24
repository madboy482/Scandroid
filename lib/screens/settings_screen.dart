import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../services/biometric_service.dart';
import '../services/local_db_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useBiometricAuth = true;
  bool _enableSmartTagging = true;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingsSection(
                    title: 'Security',
                    icon: Icons.security,
                    children: [
                      SwitchListTile(
                        title: const Text('Biometric Authentication'),
                        subtitle: const Text('Secure app access with fingerprint or face'),
                        value: _useBiometricAuth,
                        onChanged: (value) {
                          setState(() {
                            _useBiometricAuth = value;
                          });
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Clear All Data'),
                        subtitle: const Text('Delete all scanned documents'),
                        trailing: const Icon(Icons.delete_forever, color: Colors.red),
                        onTap: () => _showClearDataConfirmation(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    title: 'Features',
                    icon: Icons.featured_play_list,
                    children: [
                      SwitchListTile(
                        title: const Text('Smart Tagging'),
                        subtitle:
                            const Text('Automatically suggest tags based on document content'),
                        value: _enableSmartTagging,
                        onChanged: (value) {
                          setState(() {
                            _enableSmartTagging = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    title: 'About',
                    icon: Icons.info_outline,
                    children: [
                      ListTile(
                        title: const Text('Version'),
                        subtitle: const Text('1.0.0'),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Feedback'),
                        subtitle: const Text('Send your thoughts and suggestions'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback feature will be implemented soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all documents? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              setState(() {
                _isProcessing = true;
              });
              
              try {
                await Provider.of<DocumentProvider>(context, listen: false).clearAll();
                
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All documents have been deleted'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                  ),
                );
              } finally {
                setState(() {
                  _isProcessing = false;
                });
              }
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}