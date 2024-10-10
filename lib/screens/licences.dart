import 'package:flutter/material.dart';
import 'package:power_diyala/widgets/constants.dart';

class LicenceSimple extends StatelessWidget {
  const LicenceSimple({super.key});

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
