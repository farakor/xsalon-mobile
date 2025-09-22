import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../providers/client_history_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/appointment.dart';
import 'widgets/appointment_history_card.dart';
import 'widgets/history_filter_bottom_sheet.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем историю при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(clientHistoryProvider.notifier).loadClientHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(clientHistoryProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'История записей',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(clientHistoryProvider.notifier).refresh(user.id);
          }
        },
        child: _buildBody(historyState),
      ),
    );
  }

  Widget _buildBody(ClientHistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(currentUserProvider);
                if (user != null) {
                  ref.read(clientHistoryProvider.notifier).loadClientHistory(user.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.calendar,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет записей',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.appointments.isEmpty 
                  ? 'У вас пока нет записей в истории'
                  : 'Нет записей, соответствующих фильтрам',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildAppointmentsList(state);
  }

  Widget _buildAppointmentsList(ClientHistoryState state) {
    final appointmentsByMonth = state.appointmentsByMonth;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointmentsByMonth.length,
      itemBuilder: (context, index) {
        final monthName = appointmentsByMonth.keys.elementAt(index);
        final appointments = appointmentsByMonth[monthName]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            _buildMonthHeader(monthName, appointments.length),
            const SizedBox(height: 12),
            ...appointments.map((appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppointmentHistoryCard(appointment: appointment),
            )),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(String monthName, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HistoryFilterBottomSheet(),
    );
  }
}
