import 'package:flutter/material.dart';

class CMType {
  final String? cmType;
  CMType(this.cmType);

  List<Widget> cmTypeDrop(
    BuildContext context,
    List<TextEditingController> controllers,
    String? selectedOption1,
    String? selectedOption2,
    String? selectedOption3,
    ValueChanged<String?> onChanged1,
    ValueChanged<String?> onChanged2,
    ValueChanged<String?> onChanged3,
  ) {
    List<Widget> inputFields = [];

    if (cmType == null) {
      return inputFields;
    }

    List<String> generatorOptions1, generatorOptions2, generatorOptions3;

    switch (cmType) {
      case 'Generator':
        generatorOptions1 = ['CM Gen', 'Extra'];
        generatorOptions2 = [
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
        generatorOptions3 = [
          'During PM',
          'Planned CM',
          'Respond to Alarm',
          '3rd Party Related'
        ];
        break;
      case 'Electric':
        generatorOptions1 = ['CM Ele', 'Extra'];
        generatorOptions2 = [
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
        generatorOptions3 = ['Planned', 'Respond to Alarm'];
        break;
      case 'AC':
        generatorOptions1 = ['CM AC', 'Extra'];
        generatorOptions2 = [
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
        generatorOptions3 = ['Planned', 'Respond to Alarm'];
        break;
      case 'Civil':
        generatorOptions1 = ['CM Civil'];
        generatorOptions2 = ['Civil work'];
        generatorOptions3 = ['Civil'];
        break;
      default:
        generatorOptions1 = [];
        generatorOptions2 = [];
        generatorOptions3 = [];
    }

    inputFields.add(buildDropdown(
      context: context,
      hint: 'Category',
      value: selectedOption1,
      options: generatorOptions1,
      onChanged: onChanged1,
    ));

    if (selectedOption1 == 'Extra') {
      inputFields.add(SizedBox(height: 12));
      inputFields.add(buildDropdown(
        context: context,
        hint: 'Extra Type',
        value: selectedOption2,
        options: generatorOptions2,
        onChanged: onChanged2,
      ));
    }

    inputFields.add(SizedBox(height: 12));
    inputFields.add(buildDropdown(
      context: context,
      hint: 'Type',
      value: selectedOption3,
      options: generatorOptions3,
      onChanged: onChanged3,
    ));

    return inputFields;
  }

  Widget buildDropdown({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: DropdownButton<String>(
        hint: Text(hint,
            style:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
        isExpanded: true,
        underline: SizedBox(),
        value: value,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        onChanged: onChanged,
        dropdownColor: Theme.of(context).cardColor,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            alignment: AlignmentDirectional.center,
            child: Text(
              option,
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.normal),
            ),
          );
        }).toList(),
      ),
    );
  }
}
