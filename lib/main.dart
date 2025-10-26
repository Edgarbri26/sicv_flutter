import 'package:provider/provider.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:sicv_flutter/providers/report_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ReportProvider(),
      child: InventoryApp()
    )
  );
}
