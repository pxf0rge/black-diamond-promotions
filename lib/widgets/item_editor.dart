import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';

class ItemEditor extends StatelessWidget {
  const ItemEditor({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.onSubmit,
    this.isEditing = false,
    this.onCancel,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final VoidCallback onSubmit;
  final bool isEditing;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Item name',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Price',
              prefixText: '\$ ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (isEditing && onCancel != null)
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        _AddItemButton(onPressed: onSubmit),
      ],
    );
  }
}

class _AddItemButton extends StatefulWidget {
  const _AddItemButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddItemButton> createState() => _AddItemButtonState();
}

class _AddItemButtonState extends State<_AddItemButton> {
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
