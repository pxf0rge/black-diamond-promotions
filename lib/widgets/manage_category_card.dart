import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'confirmation_dialog.dart';
import 'item_editor.dart';

class ManageCategoryCard extends StatefulWidget {
  const ManageCategoryCard({
    super.key,
    required this.category,
    required this.onToggle,
    required this.onDelete,
    required this.onRename,
    required this.onDeleteProduct,
    required this.onEditProduct,
    required this.onAddProduct,
  });

  final CategoryGroup category;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final void Function(String newName) onRename;
  final void Function(String productId) onDeleteProduct;
  final void Function(String productId, String name, double price)
  onEditProduct;
  final void Function(String name, double price) onAddProduct;

  @override
  State<ManageCategoryCard> createState() => _ManageCategoryCardState();
}

class _ManageCategoryCardState extends State<ManageCategoryCard> {
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  String? _editingProductId;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  void _startEdit(ProductModel product) {
    setState(() {
      _editingProductId = product.id;
      _itemNameController.text = product.name;
      _itemPriceController.text = product.price.toStringAsFixed(
        product.price == product.price.roundToDouble() ? 0 : 2,
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingProductId = null;
      _itemNameController.clear();
      _itemPriceController.clear();
    });
  }

  void _submitItem() {
    final name = _itemNameController.text.trim();
    final price = double.tryParse(_itemPriceController.text) ?? 0;

    if (name.isEmpty) return;

    if (_editingProductId != null) {
      widget.onEditProduct(_editingProductId!, name, price);
      _cancelEdit();
    } else {
      widget.onAddProduct(name, price);
      _itemNameController.clear();
      _itemPriceController.clear();
    }
  }

  Future<void> _confirmDeleteCategory() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete "${widget.category.name}" and all its items?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) widget.onDelete();
  }

  Future<void> _confirmDeleteProduct(ProductModel product) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Item',
      message: 'Remove "${product.name}" from this category?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) widget.onDeleteProduct(product.id);
  }

  Future<void> _showRenameDialog() async {
    final controller = TextEditingController(text: widget.category.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      widget.onRename(result.trim());
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onToggle,
                  icon: AnimatedRotation(
                    turns: widget.category.isExpanded ? 0.25 : 0,
                    duration: AppConstants.animationDuration,
                    child: const Icon(Icons.chevron_right),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onToggle,
                    onLongPress: _showRenameDialog,
                    child: Row(
                      children: [
                        Text(
                          widget.category.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.category.itemCount} items)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showRenameDialog,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.textSecondary,
                ),
                IconButton(
                  onPressed: _confirmDeleteCategory,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  ...widget.category.products.map((product) {
                    return _ProductRow(
                      product: product,
                      isEditing: _editingProductId == product.id,
                      onEdit: () => _startEdit(product),
                      onDelete: () => _confirmDeleteProduct(product),
                    );
                  }),
                  const SizedBox(height: 12),
                  ItemEditor(
                    nameController: _itemNameController,
                    priceController: _itemPriceController,
                    onSubmit: _submitItem,
                    isEditing: _editingProductId != null,
                    onCancel: _editingProductId != null ? _cancelEdit : null,
                  ),
                ],
              ),
            ),
            crossFadeState: widget.category.isExpanded
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

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.productCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: isEditing ? AppColors.primary : Colors.transparent,
          width: isEditing ? 2 : 0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.productText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.currency(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.productText,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
