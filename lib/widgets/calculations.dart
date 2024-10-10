import 'package:flutter/material.dart';
import 'package:power_diyala/widgets/widgets.dart';

double? calculate(String inputText, double referenceValue) {
  if (inputText.isNotEmpty) {
    double inputValue = double.tryParse(inputText) ?? 0;
    return inputValue - referenceValue;
  }
  return null;
}

// Method to format input and remove leading zeros
String removeLeadingZeros(String input) {
  return input.replaceAll(RegExp(r'^0+(?!$)'), '');
}

class RuntimeCalculations extends StatelessWidget {
  final double? calculatedG1;
  final double? calculatedG2;
  final double? calculatedCP;
  final double? totalGen;
  final double? genDifference;
  final String genPerDay;
  final double? totalRT;
  final String duration;
  final String difference;

  const RuntimeCalculations({
    super.key,
    required this.calculatedG1,
    required this.calculatedG2,
    required this.calculatedCP,
    required this.totalGen,
    required this.genDifference,
    required this.genPerDay,
    required this.totalRT,
    required this.duration,
    required this.difference,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderCard(context, 'Runtime Calculations'),
        buildCalculationCard([
          buildCalculationRow(context, 'G1 RT:', calculatedG1),
          buildCalculationRow(context, 'G2 RT:', calculatedG2),
          buildCalculationRow(context, 'CP RT:', calculatedCP),
        ], Theme.of(context).cardColor),
        buildCalculationCard([
          buildCalculationRow(context, 'Gen Diff:', genDifference),
          buildCalculationRow(context, 'Total Gen:', totalGen),
          buildCalculationRow(context, 'Gen/Day:', genPerDay),
        ], Theme.of(context).cardColor),
        buildCalculationCard([
          buildCalculationRow(context, 'Total RT:', totalRT),
          buildCalculationRow(context, 'Duration:', duration),
          buildCalculationRow(context, 'Difference:', difference),
        ], Theme.of(context).cardColor),
        const SizedBox(height: 5),
        buildHeaderCard(context, 'Replacements'),
      ],
    );
  }
}
