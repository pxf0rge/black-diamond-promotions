import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'counter_widget.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final hasQuantity = quantity > 0;

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.productCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: hasQuantity ? AppColors.primary : Colors.transparent,
          width: hasQuantity ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: hasQuantity ? 0.15 : 0.08),
            blurRadius: hasQuantity ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.productText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(product.price),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: product.isFree
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  AnimatedSize(
                    duration: AppConstants.animationDuration,
                    curve: Curves.easeOutCubic,
                    child: hasQuantity
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              CounterWidget(
                                quantity: quantity,
                                onIncrement: onIncrement,
                                onDecrement: onDecrement,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subtotal: ${Formatters.currency(product.price * quantity)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: AppConstants.animationDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: hasQuantity
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : _AddButton(key: const ValueKey('add'), onPressed: onAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: AppConstants.shortAnimation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
