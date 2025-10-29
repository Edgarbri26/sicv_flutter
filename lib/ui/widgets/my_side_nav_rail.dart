import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/destinations.dart';

class MySideNavRail extends StatefulWidget {
  const MySideNavRail({super.key});

  @override
  State<MySideNavRail> createState() => _MySideNavRailState();
}

class _MySideNavRailState extends State<MySideNavRail> {
  int _selectedIndex = 0;
  double groupAlignment = 0.0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      groupAlignment: groupAlignment,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: labelType,

      destinations: destinations.map((destination) {
        return NavigationRailDestination(
          icon: destination.icon,
          label: Text(destination.label),
        );
      }).toList(),
    );
  }
}
