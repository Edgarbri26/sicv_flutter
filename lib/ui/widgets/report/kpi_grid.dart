import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_card.dart';

class KpiGrid extends StatelessWidget {
  final List<KpiData> kpis;

  const KpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Adjust breakpoints as needed
        int crossAxisCount = width < 600 ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 140, // Increased height to prevent overflow
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => KpiCard(data: kpis[index]),
        );
      },
    );
  }
}
