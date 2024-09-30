import 'dart:async';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:power_diyala/calculator/widgets.dart';
import 'package:logger/logger.dart';

class NetworkScreen extends StatefulWidget {
  final ThemeMode themeMode; // Accept current theme mode
  final Function(ThemeMode) onThemeChanged; // Function to handle theme changes

  const NetworkScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<NetworkScreen> {
  final Logger logger = Logger();
  List<Map<String, dynamic>>? _data;
  String? _selectedSiteName;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadNetworkData();
      logger.i(data); // Check what is being loaded

      if (mounted) {
        setState(() {
          _data = data;
          _siteNames = data.map((item) => item['Site name'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure this method is present
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SPMS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          PopupMenuButton<ThemeMode>(
            initialValue: widget.themeMode,
            onSelected: (value) {
              widget.onThemeChanged(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Mode'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Mode'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => showSearchableDropdown(
                        context,
                        _siteNames,
                        (selected) {
                          setState(() {
                            _selectedSiteName = selected;
                          });
                        },
                        _searchController,
                      ),
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
                              _selectedSiteName ?? 'Select a Site Name',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: Colors.grey[700]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
    );
  }
}
