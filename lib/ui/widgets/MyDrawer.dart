import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/destinations.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: destinations.map((destination) {
          return ListTile(
            leading: destination.icon,
            title: Text(destination.label),
            onTap: () {
              if (destination.route != null) {
                Navigator.pushNamed(context, destination.route!);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}