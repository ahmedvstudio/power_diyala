import 'package:power_diyala/theme_control.dart';
import 'package:flutter/material.dart';

void showSearchableDropdown(BuildContext context, List<String> siteNames,
    Function(String) onSelected, TextEditingController searchController) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 10,
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Site Name',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                    floatingLabelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    setState(() {});
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
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        shadowColor: Theme.of(context).shadowColor,
                        child: ListTile(
                          title: Text(
                            filteredSites[index],
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
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

Widget buildTextField(TextEditingController controller, String label) {
  return Expanded(
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ThemeControl.errorColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: ThemeControl.secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide:
              const BorderSide(color: ThemeControl.accentColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      style: const TextStyle(fontSize: 16.0),
    ),
  );
}

Widget buildLabelValue(BuildContext context, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: Theme.of(context).textTheme.headlineSmall),
      Text(value),
    ],
  );
}

Widget buildHeaderCard(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Divider(
          endIndent: 10,
          color: Theme.of(context).dividerColor,
        ),
      ),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      Expanded(
        child: Divider(
          indent: 10,
          color: Theme.of(context).dividerColor,
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

Column buildHeaderColumn(List<String> labels) {
  return Column(
    children: labels
        .map((label) => Text(label, style: const TextStyle(fontSize: 18)))
        .toList(),
  );
}

// Replacement colors
Column buildValueColumn(
    String title, double? value1, double? value2, List<double> thresholds) {
  double lowThreshold = thresholds[0];
  double highThreshold = thresholds[1];

  // Text color for value1
  Color textColor1;
  if (value1 == null) {
    textColor1 = Colors.grey; // Default
  } else if (value1 >= highThreshold) {
    textColor1 = Colors.red; // above
  } else if (value1 >= lowThreshold) {
    textColor1 = Colors.green; // normal
  } else {
    textColor1 = Colors.grey; // negative
  }

  Color textColor2;
  if (value2 == null) {
    textColor2 = Colors.grey;
  } else if (value2 >= highThreshold) {
    textColor2 = Colors.red;
  } else if (value2 >= lowThreshold) {
    textColor2 = Colors.green;
  } else {
    textColor2 = Colors.grey;
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
