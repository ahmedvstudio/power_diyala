import 'package:flutter/material.dart';

class ReplacementSwitch {
  final int? sheetNumber;

  ReplacementSwitch(this.sheetNumber);

  List<Widget> genSwitches(
      List<bool> switchValues, Function(int, bool) onChanged) {
    List<Widget> switchFields = [];

    if (sheetNumber == null) return switchFields;

    switch (sheetNumber) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 16:
        switchFields.add(
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Container()), // Empty spacer for alignment
                  Text('G1',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 35),
                  Text('G2',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 20),
                ],
              ),
              Divider(thickness: 1, color: Colors.grey[300]),
              _buildStyledSwitchRow(
                  'Oil & Filters', 0, 3, switchValues, onChanged),
              _buildStyledSwitchRow(
                  'Air Filter', 1, 4, switchValues, onChanged),
              _buildStyledSwitchRow('Coolant', 2, 5, switchValues, onChanged),
            ],
          ),
        );
        break;
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        switchFields.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStyledSwitchRow(
                  'Oil & filters', 0, null, switchValues, onChanged),
              _buildStyledSwitchRow(
                  'Air Filter', 1, null, switchValues, onChanged),
              _buildStyledSwitchRow(
                  'Coolant', 2, null, switchValues, onChanged),
            ],
          ),
        );
        break;
      case 15:
        // No switches for sheet 15
        break;
      default:
        break;
    }
    return switchFields;
  }

  Widget _buildStyledSwitchRow(String label, int g1Index, int? g2Index,
      List<bool> switchValues, Function(int, bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16)),
          ),
          Switch(
            value: switchValues[g1Index],
            onChanged: (bool value) {
              onChanged(g1Index, value);
              switchValues[g1Index] = value;
            },
          ),
          if (g2Index != null)
            Switch(
              value: switchValues[g2Index],
              onChanged: (bool value) {
                onChanged(g2Index, value);
                switchValues[g2Index] = value;
              },
            ),
        ],
      ),
    );
  }
}

//============================Separator===========================

class SeparatorSwitch {
  final int? sheetNumber;
  final Map<String, String?>? selectedSiteData;

  SeparatorSwitch(this.sheetNumber, this.selectedSiteData);

  List<Widget> sepSwitches(
      List<bool> switchValues, Function(int, bool) onChanged) {
    List<Widget> sepFields = [];

    if (sheetNumber == null) return sepFields;

    bool isGenSepYes = selectedSiteData?['gen sep'] == "Yes";
    bool isTankSepYes = selectedSiteData?['tank sep'] == "Yes";

    switch (sheetNumber) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 16:
        sepFields.add(
          Column(
            children: [
              _buildSeparatorSwitchRow(
                  'Gen Sep.', 6, 8, switchValues, onChanged, isGenSepYes),
              _buildSeparatorSwitchRow(
                  'Tank Sep.', 7, 9, switchValues, onChanged, isTankSepYes),
            ],
          ),
        );
        break;
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        sepFields.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSeparatorSwitchRow(
                  'Gen Sep.', 6, null, switchValues, onChanged, isGenSepYes),
              _buildSeparatorSwitchRow(
                  'Tank Sep.', 7, null, switchValues, onChanged, isTankSepYes),
            ],
          ),
        );
        break;
      case 15:
        // No separators for sheet 15
        break;
      default:
        break;
    }
    return sepFields;
  }

  Widget _buildSeparatorSwitchRow(String label, int g1Index, int? g2Index,
      List<bool> switchValues, Function(int, bool) onChanged, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16)),
          ),
          _buildSwitchWithLabel(
              g1Index, switchValues[g1Index], onChanged, isEnabled),
          if (g2Index != null)
            _buildSwitchWithLabel(
                g2Index, switchValues[g2Index], onChanged, isEnabled),
        ],
      ),
    );
  }

  Widget _buildSwitchWithLabel(int index, bool switchValue,
      Function(int, bool) onChanged, bool isEnabled) {
    return Row(
      children: [
        Switch(
          value: switchValue,
          onChanged: isEnabled
              ? (bool value) {
                  onChanged(index, value);
                }
              : null,
          activeColor: isEnabled ? null : Colors.grey[400],
        ),
      ],
    );
  }
}
