import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final teacherWalletProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  // We'll use the teacher dashboard for stats or a dedicated wallet endpoint if available
  // For now let's assume we want transaction history
  return await apiService.get('teacher/dashboard'); 
});

final teacherTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('teacher/wallet');
    return response as List<dynamic>; 
  } catch (e) {
    return [];
  }
});
