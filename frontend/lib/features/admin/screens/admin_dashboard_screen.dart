// Admin dashboard screen for KhedmaLink Flutter app
// Main admin interface with navigation to admin operations

import 'package:flutter/material.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:go_router/go_router.dart';

/// Admin dashboard screen
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'لوحة الإدارة' : 'Admin Dashboard',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(
            context,
            language == 'ar' ? 'إدارة المستخدمين' : 'User Management',
          ),
          _buildMenuItem(
            context,
            icon: Icons.people,
            title: language == 'ar' ? 'قائمة المستخدمين' : 'User List',
            subtitle: language == 'ar' ? 'عرض وإدارة جميع المستخدمين' : 'View and manage all users',
            onTap: () => context.push('/admin/users'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.verified_user,
            title: language == 'ar' ? 'قائمة التحقق' : 'Verification Queue',
            subtitle: language == 'ar' ? 'الموافقة على طلبات التحقق' : 'Approve verification requests',
            onTap: () => context.push('/admin/verification'),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(
            context,
            language == 'ar' ? 'إدارة المحتوى' : 'Content Management',
          ),
          _buildMenuItem(
            context,
            icon: Icons.delete,
            title: language == 'ar' ? 'حذف المحتوى' : 'Delete Content',
            subtitle: language == 'ar' ? 'حذف التقييمات والطلبات' : 'Delete reviews and requests',
            onTap: () => context.push('/admin/content'),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(
            context,
            language == 'ar' ? 'السجلات والتدقيق' : 'Audit Logs',
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: language == 'ar' ? 'سجلات التدقيق' : 'Audit Logs',
            subtitle: language == 'ar' ? 'عرض سجل الإجراءات الإدارية' : 'View admin action history',
            onTap: () => context.push('/admin/audit-logs'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          AppLogger.info('Navigating to: $title');
          onTap();
        },
      ),
    );
  }
}
