import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/enums/app_enums.dart';
import '../theme/app_theme.dart';

class PaymentButton extends StatefulWidget {
  const PaymentButton({
    super.key,
    required this.method,
    required this.onPressed,
    this.enabled = true,
    this.compact = false,
  });

  final PaymentMethod method;
  final VoidCallback onPressed;
  final bool enabled;
  final bool compact;

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: AppConstants.shortAnimation,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          duration: AppConstants.shortAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: widget.compact ? 10 : 14,
              horizontal: widget.compact ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(
                widget.compact ? 12 : AppConstants.borderRadius,
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: widget.compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.method.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.method.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.method.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.method.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
