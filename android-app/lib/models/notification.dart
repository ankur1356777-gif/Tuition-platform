import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      isRead: json['is_read'] ?? false,
      readAt:
          json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Get icon based on notification type
  IconData get icon {
    switch (type) {
      case 'lead_received':
        return Icons.person_add;
      case 'demo_scheduled':
        return Icons.calendar_today;
      case 'attendance_marked':
        return Icons.check_circle;
      case 'test_assigned':
        return Icons.assignment;
      case 'payment_received':
        return Icons.payment;
      case 'commission_credited':
        return Icons.account_balance_wallet;
      case 'payout_approved':
        return Icons.done_all;
      case 'system_announcement':
        return Icons.announcement;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  // Get color based on notification type
  Color get color {
    switch (type) {
      case 'lead_received':
        return Colors.blue;
      case 'demo_scheduled':
        return Colors.orange;
      case 'attendance_marked':
        return Colors.green;
      case 'test_assigned':
        return Colors.purple;
      case 'payment_received':
        return Colors.teal;
      case 'commission_credited':
        return Colors.amber;
      case 'payout_approved':
        return Colors.green;
      case 'system_announcement':
        return Colors.red;
      case 'reminder':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
