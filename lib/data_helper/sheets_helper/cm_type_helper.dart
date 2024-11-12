import 'package:flutter/material.dart';

class CMTypeDialog {
  final BuildContext context;
  final String cmType;
  final Function(String?, String?, String?) onSelected; // Update callback type

  CMTypeDialog(this.context, this.cmType, this.onSelected);

  void show() {
    final TextEditingController option1Controller = TextEditingController();
    final TextEditingController option2Controller = TextEditingController();
    final TextEditingController option3Controller = TextEditingController();

    List<String> options1 = [];
    List<String> options2 = [];
    List<String> options3 = [];

    switch (cmType) {
      case 'Generator':
        options1 = ['CM Gen', 'Extra'];
        options2 = [
          'ATP',
          'Fuel Supply',
          'Mini Project',
          'Site Audit',
          'Korek Support',
          'Clean Up 1',
          'Clean Up 2',
          'Civil Work',
          'Onsite Training',
          'Admin',
          'Inspection',
          'Adding HTS'
        ];
        options3 = [
          'During PM',
          'Planned CM',
          'Respond to Alarm',
          '3rd Party Related'
        ];
        break;
      case 'Electric':
        options1 = ['CM Ele', 'Extra'];
        options2 = [
          'ATP',
          'Fuel Supply',
          'Mini Project',
          'Site Audit',
          'Korek Support',
          'Clean Up 1',
          'Clean Up 2',
          'Civil Work',
          'Onsite Training',
          'Admin',
          'Inspection'
        ];
        options3 = ['Planned', 'Respond to Alarm'];
        break;
      case 'AC':
        options1 = ['CM AC', 'Extra'];
        options2 = [
          'ATP',
          'Fuel Supply',
          'Mini Project',
          'Site Audit',
          'Korek Support',
          'Clean Up 1',
          'Clean Up 2',
          'Civil Work',
          'Onsite Training',
          'Admin',
          'Inspection',
          'Light Activity'
        ];
        options3 = ['Planned', 'Respond to Alarm'];
        break;
      case 'Civil':
        options1 = ['CM Civil'];
        options2 = ['Civil work'];
        options3 = ['Civil'];
        break;
      default:
        return; // Invalid type
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedOption1;
        String? selectedOption2;
        String? selectedOption3;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('CM - $cmType'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown(
                      hint: 'Category',
                      value: selectedOption1,
                      options: options1,
                      onChanged: (value) {
                        setState(() {
                          selectedOption1 = value;
                          option1Controller.text = value ?? '';
                          // Reset option 2 if "Extra" is not selected
                          if (value != "Extra") {
                            option2Controller.clear();
                            selectedOption2 = null;
                          }
                        });
                      },
                    ),
                    if (selectedOption1 == "Extra") ...[
                      SizedBox(height: 12),
                      _buildDropdown(
                        hint: 'Extra Type',
                        value: selectedOption2,
                        options: options2,
                        onChanged: (value) {
                          setState(() {
                            selectedOption2 = value;
                            option2Controller.text = value ?? '';
                          });
                        },
                      ),
                    ],
                    SizedBox(height: 12),
                    _buildDropdown(
                      hint: 'Type',
                      value: selectedOption3,
                      options: options3,
                      onChanged: (value) {
                        setState(() {
                          selectedOption3 = value;
                          option3Controller.text = value ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Check if any required field is empty
                    if ((selectedOption1 == null || selectedOption1!.isEmpty) ||
                        (selectedOption1 == "Extra" &&
                            (selectedOption2 == null ||
                                selectedOption2!.isEmpty)) ||
                        (selectedOption3 == null || selectedOption3!.isEmpty)) {
                      // Show a SnackBar or some feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please fill in all required fields.')),
                      );
                    } else {
                      // Call the provided callback with the selected values
                      onSelected(
                          selectedOption1, selectedOption2, selectedOption3);
                      Navigator.of(context).pop(); // Close dialog
                    }
                  },
                  child: Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: Theme.of(context).colorScheme.tertiary, width: 2.0),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          ),
          isExpanded: true,
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          onChanged: onChanged,
          dropdownColor: Theme.of(context).cardColor,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
