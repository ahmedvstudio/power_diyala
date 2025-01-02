import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

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
      case 'Site Management':
        options1 = ['Site Management'];
        options2 = ['Corrective'];
        options3 = ['Planned', 'Respond to Alarm', '3rd Party Related'];
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedOption1;
        String? selectedOption2;
        String? selectedOption3;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 120,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            Column(
                              children: [
                                const Icon(Icons.list_alt_rounded,
                                    color: Colors.white, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'CM - $cmType',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SingleChildScrollView(
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
                                      if (value != "Extra") {
                                        option2Controller.clear();
                                        selectedOption2 = null;
                                      }
                                    });
                                  },
                                ),
                                if (selectedOption1 == "Extra") ...[
                                  const SizedBox(height: 12),
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
                                const SizedBox(height: 12),
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
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if ((selectedOption1 == null ||
                                        selectedOption1!.isEmpty) ||
                                    (selectedOption1 == "Extra" &&
                                        (selectedOption2 == null ||
                                            selectedOption2!.isEmpty)) ||
                                    (selectedOption3 == null ||
                                        selectedOption3!.isEmpty)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill in all required fields.')),
                                  );
                                } else {
                                  onSelected(selectedOption1, selectedOption2,
                                      selectedOption3);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: const Text('Select',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
            color: Theme.of(context).colorScheme.tertiary, width: 1.0),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.normal),
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
                style: const TextStyle(
                    color: ThemeControl.errorColor,
                    fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
