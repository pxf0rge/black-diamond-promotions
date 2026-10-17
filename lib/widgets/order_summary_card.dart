import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/enums/app_enums.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'payment_button.dart';
import 'success_dialog.dart';

/// Responsive order summary: side panel on tablet, compact bar + sheet on phone.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, this.useSidePanel = false});

  final bool useSidePanel;

  @override
  Widget build(BuildContext context) {
    if (useSidePanel) {
      return const _SideOrderPanel();
    }
    return const _CompactOrderBar();
  }

  static Future<void> processPayment(
    BuildContext context,
    PaymentMethod method,
  ) async {
    final cart = context.read<CartProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final catalog = context.read<CatalogProvider>();

    if (cart.isEmpty) return;

    final result = await transactionProvider.completePayment(method);
    if (result == null || !context.mounted) return;

    await cart.clear();
    await catalog.reloadForSell();

    if (!context.mounted) return;
    await SuccessDialog.show(
      context,
      receiptNumber: result.transaction.receiptNumber,
      total: result.transaction.total,
      paymentMethod: method,
    );
  }

  static void showCheckoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CheckoutSheet(),
    );
  }
}

class _SideOrderPanel extends StatelessWidget {
  const _SideOrderPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        left: false,
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Current Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text(
                            'No items yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: cart.items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        Formatters.currency(item.subtotal),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: _OrderTotals(
                    cart: cart,
                    compact: true,
                    paymentColumns: 2,
                    onPayment: (method) {
                      OrderSummaryCard.processPayment(context, method);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompactOrderBar extends StatelessWidget {
  const _CompactOrderBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Material(
          color: AppColors.card,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: cart.isEmpty
                  ? null
                  : () => OrderSummaryCard.showCheckoutSheet(context),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    _CartBadge(count: cart.totalItems),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cart.isEmpty
                                ? 'Cart empty'
                                : '${cart.totalItems} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            Formatters.currency(cart.grandTotal),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: cart.isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: cart.isEmpty ? 0.4 : 1.0,
                      duration: AppConstants.shortAnimation,
                      child: FilledButton.icon(
                        onPressed: cart.isEmpty
                            ? null
                            : () => OrderSummaryCard.showCheckoutSheet(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text(
                          'Pay',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.borderRadius),
            ),
          ),
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (cart.items.isNotEmpty) ...[
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    '${item.quantity}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Formatters.currency(item.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                        ],
                        _OrderTotals(
                          cart: cart,
                          paymentColumns: 4,
                          onPayment: (method) async {
                            Navigator.pop(context);
                            await OrderSummaryCard.processPayment(
                              context,
                              method,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _OrderTotals extends StatelessWidget {
  const _OrderTotals({
    required this.cart,
    required this.onPayment,
    this.compact = false,
    this.paymentColumns = 4,
  });

  final CartProvider cart;
  final void Function(PaymentMethod method) onPayment;
  final bool compact;
  final int paymentColumns;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SummaryRow(
          label: 'Subtotal',
          value: Formatters.currency(cart.subtotal),
          compact: compact,
        ),
        if (cart.discount > 0) ...[
          SizedBox(height: compact ? 4 : 6),
          _SummaryRow(
            label: 'Discount',
            value: '-${Formatters.currency(cart.discount)}',
            compact: compact,
          ),
        ],
        SizedBox(height: compact ? 4 : 6),
        _SummaryRow(
          label: 'Tax',
          value: Formatters.currency(cart.tax),
          compact: compact,
        ),
        SizedBox(height: compact ? 8 : 12),
        _SummaryRow(
          label: 'Total',
          value: Formatters.currency(cart.grandTotal),
          isBold: true,
          valueSize: compact ? 20 : 24,
          compact: compact,
        ),
        SizedBox(height: compact ? 12 : 16),
        _PaymentGrid(
          columns: paymentColumns,
          enabled: !cart.isEmpty,
          onPayment: onPayment,
          compact: compact,
        ),
      ],
    );
  }
}

class _PaymentGrid extends StatelessWidget {
  const _PaymentGrid({
    required this.columns,
    required this.enabled,
    required this.onPayment,
    this.compact = false,
  });

  final int columns;
  final bool enabled;
  final void Function(PaymentMethod method) onPayment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final methods = PaymentMethod.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final width = columns == 4
            ? (MediaQuery.sizeOf(context).width - 56) / 4
            : (280 - 32 - 8) / 2;
        return SizedBox(
          width: width,
          child: PaymentButton(
            method: method,
            enabled: enabled,
            compact: compact,
            onPressed: () => onPayment(method),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueSize = 16,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool isBold;
  final double valueSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 13 : (isBold ? 18 : 15),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
