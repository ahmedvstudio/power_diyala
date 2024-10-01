import 'package:flutter/material.dart';

class LicenceSimple extends StatelessWidget {
  const LicenceSimple({super.key});

  @override
  Widget build(BuildContext context) => LicensePage(
        applicationName: 'Power Diyala',
        applicationIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/aaa.png',
            width: 70,
          ),
        ),
        applicationVersion: '0.24.10',
        applicationLegalese: '© 2024 Ahmed Adnan',
      );
}
