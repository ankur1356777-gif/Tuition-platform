import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final documentServiceProvider = Provider((ref) => DocumentService());

class DocumentService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyDocuments() async {
    final response = await _api.get('documents');
    return response as List<dynamic>;
  }

  Future<void> uploadDocument(File file, String type) async {
    await _api.postMultipart(
      'documents/upload',
      {'type': type},
      {'document': file.path},
    );
  }
}
