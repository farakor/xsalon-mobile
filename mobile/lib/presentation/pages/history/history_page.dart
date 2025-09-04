import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История записей'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'История записей',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'В разработке...',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
