import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/cart/quantity_helper.dart';
import 'package:power_diyala/cart/spare_item_class.dart';
import 'package:power_diyala/cart/cm_type_helper.dart';
import 'package:power_diyala/cart/used_for_helper.dart';
import 'package:power_diyala/data_helper/database_helper.dart';

class CartScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const CartScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  final TextEditingController _searchController = TextEditingController();
  List<String> _spareNames = [];
  List<String> _spareCode = [];

  List<Map<String, dynamic>>? _spareData;
  final List<SpareItem> _selectedSpareItems = [];
  bool _isCMTypeSelected = false;
  final TextEditingController _siteController = TextEditingController();
  TextEditingController spareController = TextEditingController();
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  List<TextEditingController> genControllers = [];
  List<TextEditingController> tankControllers = [];
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
  // Variables to hold selected options from CMTypeDialog
  String? _selectedCMType;
  String? _selectedCategory;
  String? _selectedExtraType;
  String? _selectedType;
  @override
  void initState() {
    super.initState();
    genControllers = List.generate(5, (index) => TextEditingController());
    tankControllers = List.generate(5, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadSpareData();
    });
  }

  @override
  void dispose() {
    for (var controller in [
      ...genControllers,
      ...tankControllers,
      _siteController,
      spareController,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadPMData();
      logger.i(data);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  Future<void> _loadSpareData() async {
    try {
      List<Map<String, dynamic>> spareData =
          await DatabaseHelper.loadSpareData();
      logger.i(spareData);

      if (mounted) {
        setState(() {
          _spareData = spareData;
          _spareNames =
              spareData.map((item) => item['Item name'] as String).toList();
          _spareCode = spareData.map((item) => item['Code'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _updateSelectedSpareName(String spareName) {
    _spareData?.firstWhere((item) => item['Item name'] == spareName);
    setState(() {
      spareController.text = spareName;
    });
  }

  void _updateSelectedSpareCode(String spareCode) {
    _spareData?.firstWhere((item) => item['Code'] == spareCode);
    setState(() {
      spareController.text = spareCode;
    });
  }

  void showCombinedSearchableDropdown(
    BuildContext context,
    List<Map<String, dynamic>> spareData,
    TextEditingController searchController,
    Function(String) onItemSelected,
  ) {
    final List<String> combinedList = spareData.map((item) {
      String itemName = item['Item name'] as String;
      String itemCode = item['Code'] as String;
      return '$itemCode - $itemName';
    }).toList();

    showSearchableDropdown(
      context,
      combinedList,
      (selected) {
        String itemName = selected.split(' - ')[1]; // Use the correct separator
        String itemCode = selected.split(' - ')[0];

        if (itemName.isNotEmpty) {
          // Check if the list already has 15 items
          if (_selectedSpareItems.length < 15) {
            // Add the selected item to the selectedSpareItems list
            setState(() {
              _selectedSpareItems.add(SpareItem(
                name: itemName,
                code: itemCode,
                quantity: 1,
                usage: '',
                where: '',
              ));
            });
          } else {
            // Optionally, show a message to the user if the limit is reached
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('That A Lot Of Items')),
            );
          }
        }
      },
      searchController,
    );
  }

  void _showCMTypeDialog(String label) {
    CMTypeDialog(
      context,
      label,
      (String? category, String? extraType, String? type) {
        setState(() {
          _isCMTypeSelected = true;
          _selectedCMType = label;
          _selectedCategory = category;
          _selectedExtraType = extraType;
          _selectedType = type;
        });
      },
    ).show();
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spare Parts Cart',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: !_isCMTypeSelected
          ? Center(
              child: Text(
              'Create New CM ...',
              style: Theme.of(context).textTheme.titleLarge,
            ))
          : SafeArea(
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            _selectedCMType ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(_selectedType ?? ''),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_selectedCategory ?? ''),
                              Text(_selectedExtraType ?? ''),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => showCombinedSearchableDropdown(
                                context,
                                _spareData ?? [],
                                _searchController,
                                (selected) {
                                  setState(() {
                                    if (_spareNames.contains(selected)) {
                                      _updateSelectedSpareName(selected);
                                    } else if (_spareCode.contains(selected)) {
                                      _updateSelectedSpareCode(selected);
                                    }
                                  });
                                },
                              ),
                              child: Text('Add Item'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSpareItems.clear();
                                });
                              },
                              child: Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedSpareItems.length,
                      itemBuilder: (context, index) {
                        final item = _selectedSpareItems[index];
                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(fontSize: 18),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item.code,
                                  style: Theme.of(context)
                                      .listTileTheme
                                      .leadingAndTrailingTextStyle,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: UsedForHelper(
                                      cmType: _selectedCMType!,
                                      onSelected: (usage, where, _) {
                                        setState(() {
                                          item.usage = usage ?? item.usage;
                                          item.where = where ?? item.where;
                                        });
                                      }),
                                ),
                                SizedBox(
                                  width: 80, // Adjust the width as needed
                                  child: QuantitySelector(
                                    initialQuantity: item.quantity,
                                    onQuantityChanged: (newQuantity) {
                                      setState(() {
                                        item.quantity =
                                            newQuantity; // Update the item's quantity
                                      });
                                    },
                                    onDelete: () {
                                      setState(() {
                                        _selectedSpareItems.removeAt(
                                            index); // Remove the item from the list
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: _isCMTypeSelected
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).secondaryHeaderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SpeedDial(
                animatedIcon: AnimatedIcons.add_event,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                spacing: 10,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.g_mobiledata_rounded, color: Colors.white),
                    backgroundColor: Colors.green,
                    label: 'Generator',
                    onTap: () => _showCMTypeDialog("Generator"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.electric_bolt_rounded, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Electric',
                    onTap: () => _showCMTypeDialog("Electric"),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).secondaryHeaderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SpeedDial(
                animatedIcon: AnimatedIcons.add_event,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                spacing: 10,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.g_mobiledata_rounded, color: Colors.white),
                    backgroundColor: Colors.green,
                    label: 'Generator',
                    onTap: () => _showCMTypeDialog("Generator"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.electric_bolt_rounded, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Electric',
                    onTap: () => _showCMTypeDialog("Electric"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.ac_unit, color: Colors.white),
                    backgroundColor: Colors.green,
                    label: 'AC',
                    onTap: () => _showCMTypeDialog("AC"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.construction, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Civil',
                    onTap: () => _showCMTypeDialog("Civil"),
                  ),
                ],
              ),
            ),
    );
  }
}
