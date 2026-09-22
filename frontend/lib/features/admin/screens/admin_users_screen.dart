// Admin users screen for KhedmaLink Flutter app
// Displays and manages user list for admins

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/admin_models.dart';
import 'package:khedmalink/core/services/admin_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Admin users screen
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _adminService = api.AdminApiService();
  UserListResponse? _userList;
  bool _isLoading = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _adminService.listUsers(
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _userList = result;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading users: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'قائمة المستخدمين' : 'User List',
        ),
      ),
      body: _buildBody(context, language),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language == 'ar' ? 'خطأ في تحميل البيانات' : 'Error loading data',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: Text(
                language == 'ar' ? 'إعادة المحاولة' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_userList == null || _userList!.items.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'لا يوجد مستخدمين' : 'No users found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _userList!.items.length,
            itemBuilder: (context, index) {
              final user = _userList!.items[index];
              return _buildUserCard(context, user, language);
            },
          ),
        ),
        if (_userList!.total > _pageSize) _buildPagination(language),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserListItem user, String language) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.fullName ?? user.email),
        subtitle: Text(user.email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(user.getStatusDisplay(language)),
            if (user.isVerified)
              Icon(
                Icons.verified,
                size: 16,
                color: Colors.green,
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to user detail screen
          AppLogger.info('User tapped: ${user.email}');
        },
      ),
    );
  }

  Widget _buildPagination(String language) {
    final totalPages = (_userList!.total / _pageSize).ceil();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadUsers();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '$_currentPage / $totalPages',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadUsers();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
