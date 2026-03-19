import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final commissionSettingsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminServiceProvider).getCommissionSettings();
});

class CommissionSettingsScreen extends ConsumerStatefulWidget {
  const CommissionSettingsScreen({super.key});

  @override
  ConsumerState<CommissionSettingsScreen> createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends ConsumerState<CommissionSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(commissionSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commission Settings')),
      body: settingsAsync.when(
        data: (data) {
          final settings = data as List<dynamic>;
          return Form(
            key: _formKey,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: settings.length + 1, // +1 for save button
              itemBuilder: (context, index) {
                if (index == settings.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ElevatedButton(
                      onPressed: () => _saveSettings(settings),
                      child: const Text('Save Changes'),
                    ),
                  );
                }

                final setting = settings[index];
                final key = setting['key'];
                
                if (!_controllers.containsKey(key)) {
                  _controllers[key] = TextEditingController(text: setting['value'].toString());
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _controllers[key],
                    decoration: InputDecoration(
                      labelText: _formatLabel(key),
                      helperText: setting['description'],
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatLabel(String key) {
    return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Future<void> _saveSettings(List<dynamic> originalSettings) async {
    if (_formKey.currentState!.validate()) {
      final List<Map<String, dynamic>> updates = [];
      
      _controllers.forEach((key, controller) {
        updates.add({
          'key': key,
          'value': double.tryParse(controller.text) ?? 0.0,
        });
      });

      try {
        await ref.read(adminServiceProvider).updateCommissionSettings(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings updated successfully')),
          );
        }
        ref.refresh(commissionSettingsProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
