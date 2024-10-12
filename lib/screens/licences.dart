import 'package:flutter/material.dart';
import 'package:power_diyala/settings/constants.dart';

class LicencePage extends StatelessWidget {
  const LicencePage({super.key});

  @override
  Widget build(BuildContext context) => LicensePage(
        applicationName: appName,
        applicationIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            iconPath,
            width: 70,
          ),
        ),
        applicationVersion: appVersion,
        applicationLegalese: appLegalese,
      );
}
