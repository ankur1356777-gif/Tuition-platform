import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/document_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final myDocumentsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(documentServiceProvider).getMyDocuments();
});

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final _types = [
    {'label': 'Aadhar Card', 'value': 'aadhar'},
    {'label': 'PAN Card', 'value': 'pan'},
    {'label': 'Decree/Certificate', 'value': 'degree'},
    {'label': 'Other', 'value': 'other'},
  ];
  String _selectedType = 'aadhar';
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    // Note: Implementation depends on file_picker being properly configured.
    // For now, keeping it consistent with the previous logic for UI demonstration.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File selection requires additional configuration. Mocking success for UI verification.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(myDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Documents', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
              : [const Color(0xFFF0F4FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildUploadCard(isDark),
            Expanded(
              child: docsAsync.when(
                data: (docs) => _buildDocumentsList(docs, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: PremiumCard(
        glass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: DesignSystem.primary, size: 20),
                const SizedBox(width: 8),
                Text('UPLOAD NEW DOCUMENT', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types.map((t) => DropdownMenuItem(
                value: t['value'], 
                child: Text(t['label']!, style: DesignSystem.bodyMedium(color: null)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
              decoration: DesignSystem.inputDecoration('Document Type', Icons.folder_shared_rounded),
              dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'SELECT FILE & UPLOAD',
              isLoading: _isUploading,
              onPressed: _pickAndUpload,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Supported: PDF, JPG, PNG (Max 5MB)',
                style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(List<dynamic> docs, bool isDark) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.2, child: Icon(Icons.file_present_rounded, size: 60, color: isDark ? Colors.white : DesignSystem.backgroundDark)),
            const SizedBox(height: 16),
            Text('No documents uploaded yet.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final status = doc['status']?.toString().toLowerCase() ?? 'pending';
        final statusColor = status == 'approved' ? Colors.green : (status == 'rejected' ? DesignSystem.error : Colors.orange);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PremiumCard(
            glass: true,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DesignSystem.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(doc['mime_type']), color: DesignSystem.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['file_name'] ?? 'Document', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        'Type: ${doc['type'].toString().toUpperCase()} • ${DateFormat('MMM dd, yyyy').format(DateTime.parse(doc['created_at']))}',
                        style: DesignSystem.bodySmall(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status, color: statusColor),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(String? mime) {
    if (mime?.contains('pdf') ?? false) return Icons.picture_as_pdf_rounded;
    if (mime?.contains('image') ?? false) return Icons.image_rounded;
    return Icons.insert_drive_file_rounded;
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 0.5)),
    );
  }
}
