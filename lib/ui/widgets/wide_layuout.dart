import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/side_naviation_menu.dart';
import 'package:sidebarx/sidebarx.dart';

class WideLayout extends StatelessWidget {
  final SideNavigationMenu? sideNavigationMenu;
  final SidebarXController controller;
  final String appbartitle;
  final Widget child;
  const WideLayout({
    super.key,
    required this.controller,
    this.sideNavigationMenu,
    required this.appbartitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MySideBar(controller: controller),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sideNavigationMenu ?? const SizedBox.shrink(),
              Expanded(
                child: Column(
                  children: [
                    AppBarApp(title: appbartitle),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
