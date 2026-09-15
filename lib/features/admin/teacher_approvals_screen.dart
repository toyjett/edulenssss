import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/states/status_badge.dart';

class TeacherApprovalsScreen extends StatelessWidget {
  const TeacherApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: const Text('Teacher Approvals')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildApprovalCard(context, 'Angela Reyes', 'T-2024-088', 'angela@school.edu', 'May 20, 2024'),
          const SizedBox(height: 16),
          _buildApprovalCard(context, 'Ricardo Dalisay', 'T-2024-089', 'ricardo@school.edu', 'May 21, 2024'),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, String name, String id, String email, String date) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              StatusBadge.warning('Pending'),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: $id', style: const TextStyle(color: AppColors.neutralGray)),
          Text('Email: $email', style: const TextStyle(color: AppColors.neutralGray)),
          Text('Registered: $date', style: const TextStyle(color: AppColors.neutralGray)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Reject', style: TextStyle(color: AppColors.error)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: const Text('Approve', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
