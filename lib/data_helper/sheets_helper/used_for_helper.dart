import 'package:flutter/material.dart';

class UsedForHelper extends StatefulWidget {
  final String cmType;
  final Function(String?, String?, String?) onSelected;

  const UsedForHelper(
      {super.key, required this.cmType, required this.onSelected});

  @override
  UsedForHelperState createState() => UsedForHelperState();
}

class UsedForHelperState extends State<UsedForHelper> {
  String usedForValue = '';
  String onWhatValue = '';

  List<String> usedForItems = [
    'Replacement',
    'Adding',
    'Adding HTS',
    'Voucher',
    'Clean UP'
  ];

  List<String> onWhatGenItems = ['G1', 'G2', 'Fuel Tank'];
  List<String> onWhatAcItems = ['AC1', 'AC2', 'AC3', 'AC4'];

  @override
  void initState() {
    super.initState();
    usedForValue = usedForItems[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelected(usedForValue, null, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return show();
  }

  Widget show() {
    switch (widget.cmType) {
      case 'Generator':
        return _generateGeneratorInputs();
      case 'Electric':
        return _generateElectricInputs();
      case 'AC':
        return _generateACInputs();
      case 'Civil':
        return _generateCivilInputs();
      default:
        return SizedBox();
    }
  }

  Widget _generateGeneratorInputs() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, usedForItems, (value) {
              setState(() {
                usedForValue = value;
                widget.onSelected(usedForValue, onWhatValue, null);
              });
            });
          },
          child: Text(
            usedForValue.isEmpty ? 'Used For' : usedForValue,
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, onWhatGenItems, (value) {
              setState(() {
                onWhatValue = value;
                widget.onSelected(usedForValue, onWhatValue, null);
              });
            });
          },
          child: Text(
            onWhatValue.isEmpty ? 'On What' : onWhatValue,
            style: TextStyle(
                fontSize: 14,
                color: onWhatValue.isEmpty ? Colors.red : Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _generateElectricInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, usedForItems, (value) {
              setState(() {
                usedForValue = value;
                widget.onSelected(usedForValue, null, null);
              });
            });
          },
          child: Text(
            usedForValue.isEmpty ? 'Used For' : usedForValue,
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _generateACInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, usedForItems, (value) {
              setState(() {
                usedForValue = value;
                widget.onSelected(usedForValue, null, null);
              });
            });
          },
          child: Text(
            usedForValue.isEmpty ? 'Used For' : usedForValue,
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, onWhatAcItems, (value) {
              setState(() {
                onWhatValue = value;
                widget.onSelected(usedForValue, onWhatValue, null);
              });
            });
          },
          child: Text(
            onWhatValue.isEmpty ? 'On What' : onWhatValue,
            style: TextStyle(
                fontSize: 14,
                color: onWhatValue.isEmpty ? Colors.red : Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _generateCivilInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showDropdownMenu(context, usedForItems, (value) {
              setState(() {
                usedForValue = value;
                widget.onSelected(usedForValue, null, null);
              });
            });
          },
          child: Text(
            usedForValue.isEmpty ? 'Used For' : usedForValue,
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
        ),
      ],
    );
  }
}

void _showDropdownMenu(
    BuildContext context, List<String> items, Function(String) onSelect) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          shrinkWrap: true,
          children: items
              .map((item) => Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      title: Text(item),
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      );
    },
  );
}
