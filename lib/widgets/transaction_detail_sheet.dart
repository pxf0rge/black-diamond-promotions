import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/enums/app_enums.dart';
import '../models/display_models.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'confirmation_dialog.dart';
import 'primary_button.dart';

Future<void> showTransactionDetailSheet(
  BuildContext context,
  TransactionView transactionView,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => TransactionDetailSheet(
      initialView: transactionView,
    ),
  );
}

class TransactionDetailSheet extends StatefulWidget {
  const TransactionDetailSheet({super.key, required this.initialView});

  final TransactionView initialView;

  @override
  State<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<TransactionDetailSheet> {
  late PaymentMethod _paymentMethod;
  late TextEditingController _discountController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final txn = widget.initialView.transaction;
    _paymentMethod = txn.paymentMethodEnum;
    _discountController = TextEditingController(
      text: txn.discount.toStringAsFixed(
        txn.discount == txn.discount.roundToDouble() ? 0 : 2,
      ),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final discount = double.tryParse(_discountController.text.trim());
    if (discount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid discount amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final ok = await context.read<TransactionProvider>().updateTransaction(
      id: widget.initialView.transaction.id,
      paymentMethod: _paymentMethod,
      discount: discount,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (ok) _isEditing = false;
    });
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction updated')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Transaction',
      message:
          'Delete receipt ${widget.initialView.transaction.receiptNumber}? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final ok = await context.read<TransactionProvider>().deleteTransaction(
      widget.initialView.transaction.id,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final view = provider.transactions.firstWhere(
      (t) => t.transaction.id == widget.initialView.transaction.id,
      orElse: () => widget.initialView,
    );
    final txn = view.transaction;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.receiptNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.dateTime(txn.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _isEditing ? 'Cancel edit' : 'Edit',
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: _delete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...view.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}× ${item.productName}',
                        style: const TextStyle(color: AppColors.textPrimary),
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
            _AmountRow(label: 'Subtotal', value: Formatters.currency(txn.subtotal)),
            _AmountRow(label: 'Tax', value: Formatters.currency(txn.tax)),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Discount',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentMethod.values.map((method) {
                  final selected = method == _paymentMethod;
                  return ChoiceChip(
                    label: Text('${method.emoji} ${method.label}'),
                    selected: selected,
                    onSelected: (_) => setState(() => _paymentMethod = method),
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                expand: true,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),
            ] else ...[
              _AmountRow(
                label: 'Discount',
                value: Formatters.currency(txn.discount),
              ),
              _AmountRow(
                label: 'Total',
                value: Formatters.currency(txn.total),
                emphasize: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${txn.paymentMethodEnum.emoji} ${txn.paymentMethodEnum.label}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    txn.statusEnum.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasize ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: emphasize ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}
