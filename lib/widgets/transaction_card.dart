import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/enums/app_enums.dart';
import '../models/display_models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transactionView, this.onTap});

  final TransactionView transactionView;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final transaction = transactionView.transaction;
    final itemsText = transactionView.items
        .map((i) => '${i.quantity}x ${i.productName}')
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration(withShadow: false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Formatters.time(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(status: transaction.statusEnum.label),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  itemsText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: _Chip(
                        label:
                            '${transaction.paymentMethodEnum.emoji} ${transaction.paymentMethodEnum.label}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: _Chip(label: transaction.receiptNumber)),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.currency(transaction.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
