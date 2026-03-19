import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_management_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class AdminDocumentsScreen extends ConsumerWidget {
  const AdminDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(adminDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
                  : [const Color(0xFFF8FAFF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                Expanded(
                  child: docsAsync.when(
                    data: (docs) {
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('No pending documents', style: DesignSystem.bodyLarge(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final docType = doc['type']?.toString().toUpperCase() ?? 'DOCUMENT';
                          final userName = doc['user']?['name'] ?? 'Unknown User';
                          final userEmail = doc['user']?['email'] ?? '';
                          
                          return PremiumCard(
                            glass: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: DesignSystem.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.badge_rounded, color: DesignSystem.primary, size: 24),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(docType, style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                            Text(userName, style: DesignSystem.bodySmall(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Image Preview Placeholder
                                Container(
                                  height: 220,
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_rounded, size: 48, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Image Preview', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _verify(context, ref, doc['id'], 'rejected'),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: DesignSystem.error.withOpacity(0.5)),
                                            foregroundColor: DesignSystem.error,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _verify(context, ref, doc['id'], 'approved'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: DesignSystem.success,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: DesignSystem.error))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Verification',
            style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
        ],
      ),
    );
  }

  Future<void> _verify(BuildContext context, WidgetRef ref, int id, String status) async {
    try {
      await ref.read(adminManagementProvider).verifyDocument(id, status);
      ref.refresh(adminDocumentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document ${status.toUpperCase()}'),
            backgroundColor: status == 'approved' ? DesignSystem.success : DesignSystem.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
