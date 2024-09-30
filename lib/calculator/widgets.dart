import 'package:power_diyala/theme_control.dart';
import 'package:flutter/material.dart';

//Searchable Dropdown
void showSearchableDropdown(BuildContext context, List<String> siteNames,
    Function(String) onSelected, TextEditingController searchController) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor:
        Theme.of(context).secondaryHeaderColor, // Use card color for background
    elevation: 10,
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height *
                0.6, // Set a height for dropdown
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Site Name',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        setState(() {}); // Trigger a rebuild to update the list
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(0.8), // Light fill color
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update state when text changes
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: siteNames
                        .where((site) => site
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))
                        .length,
                    itemBuilder: (context, index) {
                      final filteredSites = siteNames
                          .where((site) => site
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase()))
                          .toList();
                      return Card(
                        elevation: 8, // Increase elevation for more shadow
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surface, // Set a solid background color
                        shadowColor: Theme.of(context)
                            .shadowColor, // Add shadow color for depth

                        child: ListTile(
                          title: Text(
                            filteredSites[index],
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color, // Use theme color
                            ),
                          ),
                          onTap: () {
                            onSelected(filteredSites[index]);
                            Navigator.pop(modalContext);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper method to build a TextField
Widget buildTextField(TextEditingController controller, String label) {
  return Expanded(
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: ThemeControl.errorColor), // Label color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          borderSide: const BorderSide(
              color: ThemeControl.secondaryColor), // Border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
              color: ThemeControl.accentColor,
              width: 2.0), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
              color: Colors.grey, width: 1.5), // Enabled border color
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0, horizontal: 12.0), // Padding inside the text field
      ),
      style: const TextStyle(fontSize: 16.0), // Text style
    ),
  );
}

// Helper method to build a label and value pair
Widget buildLabelValue(BuildContext context, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: Theme.of(context).textTheme.headlineSmall),
      Text(value),
    ],
  );
}

// Helper method to build a header card
Widget buildHeaderCard(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Divider(
          endIndent: 10,
          color: Theme.of(context).dividerColor, // Use context to access theme
        ),
      ),
      Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineMedium, // Use context to access theme
      ),
      Expanded(
        child: Divider(
          indent: 10,
          color: Theme.of(context).dividerColor, // Use context to access theme
        ),
      ),
    ],
  );
}

Widget buildCalculationCard(List<Widget> calculationRows, Color? color) {
  return Card(
    color: color,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: calculationRows,
    ),
  );
}

Widget buildCalculationRow(BuildContext context, String label, dynamic value) {
  return Column(
    children: [
      Text(label, style: Theme.of(context).textTheme.headlineSmall),
      Text(value != null ? value.toString() : 'N/A'),
    ],
  );
}

// Helper method to build the header column
Column buildHeaderColumn(List<String> labels) {
  return Column(
    children: labels
        .map((label) => Text(label, style: const TextStyle(fontSize: 18)))
        .toList(),
  );
}

//replacement colors
Column buildValueColumn(
    String title, double? value1, double? value2, List<double> thresholds) {
  // Extract thresholds from the list
  double lowThreshold = thresholds[0];
  double highThreshold = thresholds[1];

  // Determine text color for value1
  Color textColor1;
  if (value1 == null) {
    textColor1 = Colors.grey; // Default color if value is null
  } else if (value1 >= highThreshold) {
    textColor1 = Colors.red; // Color for values above highThreshold
  } else if (value1 >= lowThreshold) {
    textColor1 = Colors.green; // Color for values within the normal range
  } else {
    textColor1 =
        Colors.grey; // Default color for negative values (if applicable)
  }

  // Determine text color for value2
  Color textColor2;
  if (value2 == null) {
    textColor2 = Colors.grey; // Default color if value is null
  } else if (value2 >= highThreshold) {
    textColor2 = Colors.red; // Color for values above highThreshold
  } else if (value2 >= lowThreshold) {
    textColor2 = Colors.green; // Color for values within the normal range
  } else {
    textColor2 =
        Colors.grey; // Default color for negative values (if applicable)
  }

  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Divider(
        height: 5,
        endIndent: 10,
        color: ThemeData().dividerColor,
      ),
      Text(
        value1 != null ? value1.toStringAsFixed(0) : 'N/A',
        style: TextStyle(
            color: textColor1,
            fontSize: 17,
            fontWeight: FontWeight.bold), // Set the text color for value1
      ),
      Text(
        value2 != null ? value2.toStringAsFixed(0) : 'N/A',
        style: TextStyle(
            color: textColor2,
            fontSize: 17,
            fontWeight: FontWeight.bold), // Set the text color for value2
      ),
    ],
  );
}
