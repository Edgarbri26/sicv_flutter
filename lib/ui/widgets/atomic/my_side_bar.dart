import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/main.dart';
import 'package:sicv_flutter/models/destinations.dart';
import 'package:sidebarx/sidebarx.dart';

class MySideBar extends StatelessWidget {
  const MySideBar({Key? key, required SidebarXController controller})
    : _controller = controller,
      super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          // borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: AppColors.primary.withValues(alpha: 0.1),
        textStyle: TextStyle(color: AppColors.textPrimary),
        selectedTextStyle: const TextStyle(color: AppColors.secondary),
        hoverTextStyle: const TextStyle(
          color: AppColors.info,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: AppColors.textSecondary),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.37)),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 30),
          ],
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary, size: 25),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 25),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(color: AppColors.background),
      ),
      footerDivider: Divider(),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.person),
            // child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        ...destinationsPages.map(
          (destination) => SidebarXItem(
            icon: destination.icon,
            label: destination.label,
            onTap: () {
              Navigator.pushReplacementNamed(context, destination.route!);
            },
          ),
        ),
      ],

      footerItems: [
        SidebarXItem(
          icon: Icons.settings,
          label: 'Configuración',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),

        SidebarXItem(
          icon: Icons.logout,
          label: 'Cerrar Sesión',
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
        ),
      ],
    );
  }
}
