import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  // final String? trend;
  KpiData(this.title, this.value, this.icon, this.color);
}

class KpiCard extends StatelessWidget {
  final KpiData data;

  const KpiCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 140;

          // Responsive font sizing logic
          // Base size 18, scales slightly with width restricted to sensible limits
          final double valueFontSize = (width / 10).clamp(16.0, 24.0);
          final double titleFontSize = (width / 12).clamp(10.0, 14.0);
          final double iconSize = (width / 6).clamp(20.0, 32.0);

          if (isCompact) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(data.icon, color: data.color, size: iconSize),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  data.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: titleFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }

          return Row(
            spacing: AppSizes.spacingS,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
                ),
                child: Icon(data.icon, color: data.color, size: iconSize),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.value,
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      data.title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: titleFontSize),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
