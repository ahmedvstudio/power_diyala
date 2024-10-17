import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/data_helper/spms_tables_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Spms>> spmsData;
  int selectedStartYear = 2020;
  int selectedEndYear = 2024;
  List<int> availableYears =
      List.generate(5, (index) => 2020 + index); // Years from 2020 to 2024

  String selectedComponent = 'Search Item Name';
  List<String> componentOptions = [
    'Battery',
    'Starter Motor',
    'Dynamo',
    'Radiator',
    'Fan belt',
    'AVR',
    'Protection Control',
    'Charger',
    'Selenoid',
    'Water Pump',
    'Water Pump Pulley',
    'Coolant Level Sensor',
    'Oil Sensor',
    'Rocker Arm Gasket',
    'Cylinder Head Cover Gasket',
    'Rear Oil Seal',
    'Front Oil Seal',
    'Oil Pan Gasket',
    'Timing Case Washer',
    'Fuel Injection Pump',
    'Fuel Lift Pump',
    'Noozle',
    'Temperature Sensor',
  ];

  @override
  void initState() {
    super.initState();
    spmsData = fetchSpmsData();
  }

  final TextEditingController searchController = TextEditingController();

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
                      labelText: 'Search Item Name',
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                      floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
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
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
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

  Future<List<Spms>> fetchSpmsData() async {
    final rawData = await DatabaseHelper.loadSPMSData();
    logger.d('Raw data: $rawData');
    return List.generate(rawData.length, (i) => Spms.fromMap(rawData[i]));
  }

  List<Spms> filterSpmsData(List<Spms> spmsList) {
    return spmsList.where((spms) {
      DateTime? replacementDateG1 =
          getReplacementDate(selectedComponent, 'G1', spms);
      DateTime? replacementDateG2 =
          getReplacementDate(selectedComponent, 'G2', spms);

      // The year filter has been removed
      return replacementDateG1 != null || replacementDateG2 != null;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                showSearchableDropdown(context, componentOptions, (selected) {
                  setState(() {
                    selectedComponent =
                        selected; // Update the selected component
                  });
                }, searchController);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedComponent,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
              child: FutureBuilder<List<Spms>>(
            future: spmsData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data found.'));
              }

              final filteredList =
                  filterSpmsData(snapshot.data!); // Apply filter

              // Prepare data for the chart with selected years
              Map<int, int> yearCounts = {
                for (var i = selectedStartYear; i <= selectedEndYear; i++) i: 0
              };

              for (var spms in filteredList) {
                DateTime? replacementDateG1 =
                    getReplacementDate(selectedComponent, 'G1', spms);
                DateTime? replacementDateG2 =
                    getReplacementDate(selectedComponent, 'G2', spms);

                if (replacementDateG1 != null &&
                    replacementDateG1.year >= selectedStartYear &&
                    replacementDateG1.year <= selectedEndYear) {
                  yearCounts[replacementDateG1.year] =
                      (yearCounts[replacementDateG1.year] ?? 0) + 1;
                }
                if (replacementDateG2 != null &&
                    replacementDateG2.year >= selectedStartYear &&
                    replacementDateG2.year <= selectedEndYear) {
                  yearCounts[replacementDateG2.year] =
                      (yearCounts[replacementDateG2.year] ?? 0) + 1;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              // Disable the top titles
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                          ),

                          borderData: FlBorderData(show: true),
                          gridData: FlGridData(show: true), // Show grid lines
                          barGroups: yearCounts.entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key, // Year as x value
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: Colors.tealAccent,
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey, // Add border color
                                    width: 1,
                                  ),
                                  width: 15, // Width of the bars
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      )),
                  Expanded(
                    child: FutureBuilder<List<Spms>>(
                      future: spmsData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No data found.'));
                        }

                        final filteredList = filterSpmsData(snapshot.data!);
                        Map<int, Map<int, List<Widget>>>
                            yearMonthGroupedWidgets = {};

                        // Group the data by year and month
                        for (var spms in filteredList) {
                          DateTime? replacementDateG1 =
                              getReplacementDate(selectedComponent, 'G1', spms);
                          DateTime? replacementDateG2 =
                              getReplacementDate(selectedComponent, 'G2', spms);

                          if (replacementDateG1 != null &&
                              replacementDateG1.year >= selectedStartYear &&
                              replacementDateG1.year <= selectedEndYear) {
                            int year = replacementDateG1.year;
                            int month = replacementDateG1.month;

                            if (!yearMonthGroupedWidgets.containsKey(year)) {
                              yearMonthGroupedWidgets[year] = {};
                            }
                            if (!yearMonthGroupedWidgets[year]!
                                .containsKey(month)) {
                              yearMonthGroupedWidgets[year]![month] = [];
                            }

                            yearMonthGroupedWidgets[year]![month]!.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 8.0),
                                child: ListTile(
                                  leading: Icon(Icons.looks_one_rounded),
                                  title: Text(
                                    '${spms.siteName} G1',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.blue),
                                  ),
                                  subtitle: Text(
                                    formatDate(replacementDateG1),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          }

                          if (replacementDateG2 != null &&
                              replacementDateG2.year >= selectedStartYear &&
                              replacementDateG2.year <= selectedEndYear) {
                            int year = replacementDateG2.year;
                            int month = replacementDateG2.month;

                            if (!yearMonthGroupedWidgets.containsKey(year)) {
                              yearMonthGroupedWidgets[year] = {};
                            }
                            if (!yearMonthGroupedWidgets[year]!
                                .containsKey(month)) {
                              yearMonthGroupedWidgets[year]![month] = [];
                            }

                            yearMonthGroupedWidgets[year]![month]!.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 8.0),
                                child: ListTile(
                                  leading: Icon(Icons.looks_two_rounded),
                                  title: Text(
                                    '${spms.siteName} G2',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.teal),
                                  ),
                                  subtitle: Text(
                                    formatDate(replacementDateG2),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        // Build the widgets for display
                        List<Widget> displayWidgets = [];

                        var sortedYears = yearMonthGroupedWidgets.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        for (var year in sortedYears) {
                          List<Widget> monthWidgets = [];

                          var sortedMonths = yearMonthGroupedWidgets[year]!
                              .keys
                              .toList()
                            ..sort((a, b) => b.compareTo(a));

                          for (var month in sortedMonths) {
                            monthWidgets.add(
                              ExpansionTile(
                                title: Text(
                                  '$month',
                                ),
                                children: yearMonthGroupedWidgets[year]![month]!
                                    .map((widget) => widget)
                                    .toList(),
                              ),
                            );
                          }

                          displayWidgets.add(
                            ExpansionTile(
                              title: Text(
                                '$year',
                              ),
                              children: monthWidgets,
                            ),
                          );
                        }

                        return ListView(
                          children: displayWidgets,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          )),
        ],
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null || date.year == 1970) return '1/1/1970';
    return '${date.day}/${date.month}/${date.year}';
  }
}

DateTime? getReplacementDate(String component, String group, Spms spms) {
  switch (component) {
    case 'Starter Motor':
      return group == 'G1'
          ? (spms.starterG1.year != 1970 ? spms.starterG1 : null)
          : (spms.starterG2.year != 1970 ? spms.starterG2 : null);
    case 'Dynamo':
      return group == 'G1'
          ? (spms.dynamoG1.year != 1970 ? spms.dynamoG1 : null)
          : (spms.dynamoG2.year != 1970 ? spms.dynamoG2 : null);
    case 'Protection Control':
      return group == 'G1'
          ? (spms.protectionG1.year != 1970 ? spms.protectionG1 : null)
          : (spms.protectionG2.year != 1970 ? spms.protectionG2 : null);
    case 'AVR':
      return group == 'G1'
          ? (spms.avrG1.year != 1970 ? spms.avrG1 : null)
          : (spms.avrG2.year != 1970 ? spms.avrG2 : null);
    case 'Charger':
      return group == 'G1'
          ? (spms.chargerG1.year != 1970 ? spms.chargerG1 : null)
          : (spms.chargerG2.year != 1970 ? spms.chargerG2 : null);
    case 'Radiator':
      return group == 'G1'
          ? (spms.radiatorG1.year != 1970 ? spms.radiatorG1 : null)
          : (spms.radiatorG2.year != 1970 ? spms.radiatorG2 : null);
    case 'Fan belt':
      return group == 'G1'
          ? (spms.fanbeltG1.year != 1970 ? spms.fanbeltG1 : null)
          : (spms.fanbeltG2.year != 1970 ? spms.fanbeltG2 : null);
    case 'Water Pump':
      return group == 'G1'
          ? (spms.waterpumpG1.year != 1970 ? spms.waterpumpG1 : null)
          : (spms.waterpumpG2.year != 1970 ? spms.waterpumpG2 : null);
    case 'Battery':
      return group == 'G1'
          ? (spms.batteryG1.year != 1970 ? spms.batteryG1 : null)
          : (spms.batteryG2.year != 1970 ? spms.batteryG2 : null);
    case 'Selenoid':
      return group == 'G1'
          ? (spms.selenoidG1.year != 1970 ? spms.selenoidG1 : null)
          : (spms.selenoidG2.year != 1970 ? spms.selenoidG2 : null);
    case 'Water Pump Pulley':
      return group == 'G1'
          ? (spms.waterpulleyG1.year != 1970 ? spms.waterpulleyG1 : null)
          : (spms.waterpulleyG2.year != 1970 ? spms.waterpulleyG2 : null);
    case 'Coolant Level Sensor':
      return group == 'G1'
          ? (spms.levelsensorG1.year != 1970 ? spms.levelsensorG1 : null)
          : (spms.levelsensorG2.year != 1970 ? spms.levelsensorG2 : null);
    case 'Oil Sensor':
      return group == 'G1'
          ? (spms.oilsensorG1.year != 1970 ? spms.oilsensorG1 : null)
          : (spms.oilsensorG2.year != 1970 ? spms.oilsensorG2 : null);
    case 'Rocker Arm Gasket':
      return group == 'G1'
          ? (spms.rockerG1.year != 1970 ? spms.rockerG1 : null)
          : (spms.rockerG2.year != 1970 ? spms.rockerG2 : null);
    case 'Cylinder Head Cover Gasket':
      return group == 'G1'
          ? (spms.cylinderG1.year != 1970 ? spms.cylinderG1 : null)
          : (spms.cylinderG2.year != 1970 ? spms.cylinderG2 : null);
    case 'Rear Oil Seal':
      return group == 'G1'
          ? (spms.rearG1.year != 1970 ? spms.rearG1 : null)
          : (spms.rearG2.year != 1970 ? spms.rearG2 : null);
    case 'Front Oil Seal':
      return group == 'G1'
          ? (spms.frontG1.year != 1970 ? spms.frontG1 : null)
          : (spms.frontG2.year != 1970 ? spms.frontG2 : null);
    case 'Oil Pan Gasket':
      return group == 'G1'
          ? (spms.panG1.year != 1970 ? spms.panG1 : null)
          : (spms.panG2.year != 1970 ? spms.panG2 : null);
    case 'Timing Case Washer':
      return group == 'G1'
          ? (spms.timingG1.year != 1970 ? spms.timingG1 : null)
          : (spms.timingG2.year != 1970 ? spms.timingG2 : null);
    case 'Fuel Injection Pump':
      return group == 'G1'
          ? (spms.injectionG1.year != 1970 ? spms.injectionG1 : null)
          : (spms.injectionG2.year != 1970 ? spms.injectionG2 : null);
    case 'Fuel Lift Pump':
      return group == 'G1'
          ? (spms.liftpumpG1.year != 1970 ? spms.liftpumpG1 : null)
          : (spms.liftpumpG2.year != 1970 ? spms.liftpumpG2 : null);
    case 'Noozle':
      return group == 'G1'
          ? (spms.noozleG1.year != 1970 ? spms.noozleG1 : null)
          : (spms.noozleG2.year != 1970 ? spms.noozleG2 : null);
    case 'Temperature Sensor':
      return group == 'G1'
          ? (spms.tempG1.year != 1970 ? spms.tempG1 : null)
          : (spms.tempG2.year != 1970 ? spms.tempG2 : null);

    default:
      return null; // DateTime(1970) to 1/1/1970 if null
  }
}
