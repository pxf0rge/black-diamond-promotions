import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/enums/app_enums.dart';
import '../theme/app_theme.dart';

class PaymentPieChart extends StatelessWidget {
  const PaymentPieChart({super.key, required this.breakdown});

  final Map<PaymentMethod, double> breakdown;

  static const _colors = [
    AppColors.primary,
    Color(0xFF42A5F5),
    Color(0xFFFFA726),
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return const Center(
        child: Text(
          'No payment data yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 320;

        final legend = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(PaymentMethod.values.length, (i) {
            final method = PaymentMethod.values[i];
            final value = breakdown[method] ?? 0;
            final pct = total > 0 ? (value / total * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${method.label} ($pct%)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        );

        if (stacked) {
          return Column(
            children: [
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    values: PaymentMethod.values
                        .map((m) => breakdown[m] ?? 0)
                        .toList(),
                    colors: _colors,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 12),
              legend,
            ],
          );
        }

        return SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _PieChartPainter(
                    values: PaymentMethod.values
                        .map((m) => breakdown[m] ?? 0)
                        .toList(),
                    colors: _colors,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: legend),
            ],
          ),
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    final holePaint = Paint()..color = AppColors.card;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({super.key, required this.hourlyData});

  final List<double> hourlyData;

  @override
  Widget build(BuildContext context) {
    final maxValue = hourlyData.fold(0.0, math.max);
    if (maxValue == 0) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No revenue data yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(hourlyData.length, (i) {
          final value = hourlyData[i];
          final heightFactor = value / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: 120 * heightFactor.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${i + 8}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TopListWidget extends StatelessWidget {
  const TopListWidget({super.key, required this.title, required this.items});

  final String title;
  final List<MapEntry<String, int>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'No $title data yet',
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }

    final maxValue = items.first.value;

    return Column(
      children: items.take(5).map((entry) {
        final fraction = maxValue > 0 ? entry.value / maxValue : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 6,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
