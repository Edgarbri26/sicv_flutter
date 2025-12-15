import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget? trailing;
  final Widget? leading;
  const AppCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
          width: 3,
        ),
      ),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
          child: leading,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppSizes.bodyM,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subTitle,
          style: TextStyle(
            fontSize: AppSizes.bodyS,
            color: Theme.of(context).hintColor,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
