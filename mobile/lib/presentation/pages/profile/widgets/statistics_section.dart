import 'package:flutter/material.dart';

import '../../../../data/models/staff_statistics.dart';
import '../../../theme/app_theme.dart';

class StatisticsSection extends StatefulWidget {
  final StaffStatistics statistics;

  const StatisticsSection({
    super.key,
    required this.statistics,
  });

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  String _selectedPeriod = 'Последние 6 месяцев';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          // Main Statistics
          _buildMainStatistics(),
          const SizedBox(height: 24),
          // Performance Metrics
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          // Service Statistics
          _buildServiceStatistics(),
          const SizedBox(height: 24),
          // Revenue Chart
          _buildRevenueChart(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      'Последние 30 дней',
      'Последние 3 месяца',
      'Последние 6 месяцев',
      'Текущий год',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Период статистики',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    period,
                    style: AppTheme.bodySmall.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Основная статистика',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Общий доход',
                  _formatPrice(widget.statistics.totalRevenue),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Записей',
                  '${widget.statistics.totalAppointments}',
                  Icons.event,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Клиентов',
                  '${widget.statistics.totalClients}',
                  Icons.people,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Рейтинг',
                  '${widget.statistics.averageRating}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Показатели эффективности',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Процент выполнения',
            '${widget.statistics.completionRate.toStringAsFixed(1)}%',
            widget.statistics.completionRate,
            Colors.green,
          ),
          _buildMetricRow(
            'Процент отмен',
            '${widget.statistics.cancellationRate.toStringAsFixed(1)}%',
            widget.statistics.cancellationRate,
            Colors.red,
          ),
          _buildMetricRow(
            'Повторные клиенты',
            '${widget.statistics.repeatClientRate.toStringAsFixed(1)}%',
            widget.statistics.repeatClientRate,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.design_services, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Популярные услуги',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.statistics.serviceStats.entries
              .take(5)
              .map((entry) => _buildServiceRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Доход по месяцам',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, String value, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String service, int count) {
    final maxCount = widget.statistics.serviceStats.values.reduce((a, b) => a > b ? a : b);
    final percentage = count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              service,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final entries = widget.statistics.monthlyRevenue.entries.toList();
    final maxRevenue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: entries.map((entry) {
        final height = (entry.value / maxRevenue) * 160;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.key.substring(0, 3),
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatPrice(double price) {
    return '${(price / 1000).toStringAsFixed(0)} тыс. сум';
  }
}
