import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/enums/app_enums.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'product_tile.dart';

class ExpandableCategory extends StatelessWidget {
  const ExpandableCategory({
    super.key,
    required this.category,
    required this.onToggle,
    required this.getQuantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CategoryGroup category;
  final VoidCallback onToggle;
  final int Function(String productId) getQuantity;
  final void Function(ProductModel product) onAdd;
  final void Function(String productId) onIncrement;
  final void Function(String productId) onDecrement;

  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      child: Column(
        children: [
          _CategoryHeader(category: category, onToggle: onToggle),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: category.products.map((product) {
                  final qty = getQuantity(product.id);
                  return ProductTile(
                    product: product,
                    quantity: qty,
                    onAdd: () => onAdd(product),
                    onIncrement: () => onIncrement(product.id),
                    onDecrement: () => onDecrement(product.id),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: category.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppConstants.animationDuration,
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.child, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: child,
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.onToggle});

  final CategoryGroup category;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedRotation(
                turns: category.isExpanded ? 0.25 : 0,
                duration: AppConstants.animationDuration,
                curve: Curves.easeOutCubic,
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 4),
              Text(category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '(${category.itemCount} items)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
