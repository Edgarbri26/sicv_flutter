import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/utils/date_utils.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final double amountBs;
  final DateTime date;
  final bool isIncome;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.amountBs,
    required this.date,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final currencyBs = NumberFormat.currency(symbol: 'Bs. ');
    final color = isIncome ? Colors.green : Colors.red;
    // Adjust icon background opacity for dark mode visibility if needed, or rely on color
    final iconBg = isIncome
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);
    final icon = isIncome
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      decoration: BoxDecoration(
        // Use Theme.of(context).cardColor for background
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(
        //   width: 3,
        //   // Use theme divider color or generic border
        //   style: BorderStyle.solid,
        //   color: Theme.of(context).dividerColor,
        // ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.format(date),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${isIncome ? '+' : '-'}${currency.format(amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      "${isIncome ? '+' : '-'}${currencyBs.format(amountBs)}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
