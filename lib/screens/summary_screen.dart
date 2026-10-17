import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/enums/app_enums.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_header.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_detail_sheet.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Consumer<TransactionProvider>(
        builder: (context, txnProvider, _) {
          if (txnProvider.errorMessage != null) {
            return _ErrorState(
              message: txnProvider.errorMessage!,
              onRetry: () {
                txnProvider.clearError();
                txnProvider.refresh();
              },
            );
          }

          final isWide =
              MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;
          final isLarge =
              MediaQuery.sizeOf(context).width >=
              AppConstants.largeTabletBreakpoint;

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: txnProvider.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(isWide ? 24 : 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSearchAndFilter(txnProvider),
                      const SizedBox(height: 16),
                      _buildStatsGrid(isLarge),
                      const SizedBox(height: 16),
                      if (isLarge)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPaymentSection(txnProvider)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRevenueChart(txnProvider)),
                          ],
                        )
                      else ...[
                        _buildPaymentSection(txnProvider),
                        const SizedBox(height: 16),
                        _buildRevenueChart(txnProvider),
                      ],
                      const SizedBox(height: 16),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTopList(
                                'Top Selling Categories',
                                txnProvider.topCategories,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTopList(
                                'Top Selling Products',
                                txnProvider.topProducts,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTopList(
                          'Top Selling Categories',
                          txnProvider.topCategories,
                        ),
                        const SizedBox(height: 16),
                        _buildTopList(
                          'Top Selling Products',
                          txnProvider.topProducts,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTransactionsList(txnProvider),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(TransactionProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 480;
        final searchField = CustomTextField(
          controller: _searchController,
          hintText: 'Search transactions...',
          prefixIcon: Icons.search,
          onChanged: provider.setSearchQuery,
        );
        final actions = Row(
          mainAxisSize: stacked ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (stacked)
              Expanded(
                child: _FilterButton(
                  dateFilter: provider.dateFilter,
                  customStart: provider.customStart,
                  onTap: () => _showFilterSheet(provider),
                  expanded: true,
                ),
              )
            else
              _FilterButton(
                dateFilter: provider.dateFilter,
                customStart: provider.customStart,
                onTap: () => _showFilterSheet(provider),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                final path = await provider.exportTransactions();
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Exported to $path')));
              },
              icon: const Icon(Icons.file_download_outlined),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const SizedBox(height: 10), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            actions,
          ],
        );
      },
    );
  }

  Future<void> _showFilterSheet(TransactionProvider provider) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Today',
                    selected: provider.dateFilter == DateFilterType.today,
                    onTap: () {
                      provider.setDateFilter(DateFilterType.today);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Yesterday',
                    selected: provider.dateFilter == DateFilterType.yesterday,
                    onTap: () {
                      provider.setDateFilter(DateFilterType.yesterday);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Last 7 Days',
                    selected: provider.dateFilter == DateFilterType.last7Days,
                    onTap: () {
                      provider.setDateFilter(DateFilterType.last7Days);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Last 30 Days',
                    selected: provider.dateFilter == DateFilterType.last30Days,
                    onTap: () {
                      provider.setDateFilter(DateFilterType.last30Days);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'All',
                    selected: provider.dateFilter == DateFilterType.all,
                    onTap: () {
                      provider.setDateFilter(DateFilterType.all);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear filters'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(bool isLarge) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final stats = [
          (
            'Today\'s Revenue',
            Formatters.currency(provider.todayRevenue),
            Icons.attach_money,
            AppColors.primary,
          ),
          (
            'Transactions',
            '${provider.todayTransactionCount}',
            Icons.receipt_long,
            const Color(0xFF42A5F5),
          ),
          (
            'Average Sale',
            Formatters.currency(provider.averageSale),
            Icons.trending_up,
            AppColors.success,
          ),
          (
            'Items Sold',
            '${provider.itemsSoldToday}',
            Icons.inventory_2_outlined,
            const Color(0xFFFFA726),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            return GridView.count(
              crossAxisCount: isLarge ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isLarge ? 1.6 : (isCompact ? 0.95 : 1.05),
              children: stats
                  .map(
                    (s) => StatisticTile(
                      label: s.$1,
                      value: s.$2,
                      icon: s.$3,
                      color: s.$4,
                      compact: !isLarge,
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentSection(TransactionProvider provider) {
    return DashboardCard(
      title: 'Payment Breakdown',
      child: Column(
        children: [
          PaymentPieChart(breakdown: provider.paymentBreakdown),
          const SizedBox(height: 16),
          ...PaymentMethod.values.map((method) {
            final amount = provider.paymentBreakdown[method] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${method.emoji} ${method.label}',
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.currency(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(TransactionProvider provider) {
    return DashboardCard(
      title: 'Hourly Revenue',
      child: RevenueBarChart(hourlyData: provider.hourlyRevenue),
    );
  }

  Widget _buildTopList(String title, List<MapEntry<String, int>> items) {
    return DashboardCard(
      title: title,
      child: TopListWidget(title: title, items: items),
    );
  }

  Widget _buildTransactionsList(TransactionProvider provider) {
    final transactions = provider.filteredTransactions;

    return DashboardCard(
      title: 'Recent Transactions',
      trailing: Text(
        '${transactions.length} total',
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      child: transactions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : Column(
              children: transactions
                  .map(
                    (t) => TransactionCard(
                      transactionView: t,
                      onTap: () => showTransactionDetailSheet(context, t),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.dateFilter,
    required this.customStart,
    required this.onTap,
    this.expanded = false,
  });

  final DateFilterType dateFilter;
  final DateTime? customStart;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isActive = dateFilter != DateFilterType.today;
    return Material(
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 12 : 14,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: expanded
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.filter_list,
                size: 18,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _filterLabel(dateFilter),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _filterLabel(DateFilterType filter) {
    switch (filter) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return '7 Days';
      case DateFilterType.last30Days:
        return '30 Days';
      case DateFilterType.custom:
        return customStart != null ? Formatters.date(customStart!) : 'Custom';
      case DateFilterType.all:
        return 'All';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
