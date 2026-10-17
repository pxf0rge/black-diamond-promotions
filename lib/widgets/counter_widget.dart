import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CounterButton(
          icon: Icons.remove,
          onPressed: onDecrement,
        ),
        AnimatedSwitcher(
          duration: AppConstants.shortAnimation,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Container(
            key: ValueKey(quantity),
            width: 44,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.productText,
              ),
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.add,
          onPressed: onIncrement,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _CounterButton extends StatefulWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  State<_CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<_CounterButton> {
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
          width: AppConstants.minTouchTarget,
          height: AppConstants.minTouchTarget,
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.isPrimary ? Colors.white : AppColors.productText,
            size: 22,
          ),
        ),
      ),
    );
  }
}
