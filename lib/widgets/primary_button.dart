import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.expand = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool expand;
  final Color? color;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final child = AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: AppConstants.shortAnimation,
      child: Material(
        color: widget.isOutlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: widget.isOutlined
                ? BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: color, width: 1.5),
                  )
                : null,
            child: widget.isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isOutlined ? color : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize:
                        widget.expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isOutlined ? color : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.isOutlined ? color : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return child;
  }
}
