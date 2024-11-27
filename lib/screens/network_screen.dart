import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/widgets/widgets.dart';
import 'package:logger/logger.dart';

class NetworkScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const NetworkScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  NetworkScreenState createState() => NetworkScreenState();
}

class NetworkScreenState extends State<NetworkScreen> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  List<Map<String, dynamic>>? _data;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFromManager();
    });
  }

  Future<void> _loadDataFromManager() async {
    try {
      // Load Network Data
      _data = DataManager().getNetworkData();
      _siteNames =
          _data?.map((item) => item['Site name'] as String).toList() ?? [];

      logger.i("Loaded Network data: $_data");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  ListTile _buildListTile(String title, IconData icon, String key) {
    return ListTile(
      title: Text('$title: '),
      leading: Icon(icon),
      subtitle: Text('${_selectedSiteData![key] ?? '-'}'),
    );
  }

  Widget _buildExpansionTile(String title, List<Map<String, dynamic>> items) {
    return ExpansionTile(
      title: Text(title),
      children: items.map((item) {
        return _buildListTile(item['title'], item['icon'], item['key']);
      }).toList(),
    );
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  void _updateSelectedSiteData(String siteName) {
    // Find the data for the selected site
    final selectedSite =
        _data?.firstWhere((item) => item['Site name'] == siteName);
    setState(() {
      _selectedSiteData = selectedSite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedSiteData != null) ...[
                        ListTile(
                          title: Text(
                            '${_selectedSiteData!['Site name'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          leading: const Icon(Icons.cell_tower_rounded,
                              color: Colors.blue),
                          subtitle: Text(
                            '${_selectedSiteData!['Site Code'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.teal),
                          ),
                          onTap: () => showSearchableDropdown(
                            context,
                            _siteNames,
                            (selected) {
                              setState(() {
                                _updateSelectedSiteData(selected);
                              });
                            },
                            _searchController,
                          ),
                          tileColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35)),
                        ),
                        const SizedBox(height: 8),
                        _buildExpansionTile('General', [
                          {
                            'title': 'Area',
                            'icon': Icons.location_on,
                            'key': 'Area'
                          },
                          {
                            'title': 'Sub office',
                            'icon': Icons.business_center,
                            'key': 'Sub office'
                          },
                          {
                            'title': 'Zone',
                            'icon': Icons.location_searching,
                            'key': 'Zone'
                          },
                          {
                            'title': 'Site on air',
                            'icon': Icons.signal_cellular_alt,
                            'key': 'Site on air'
                          },
                          {
                            'title': 'TG',
                            'icon': Icons.network_check,
                            'key': 'TG'
                          },
                          {
                            'title': 'SUB name',
                            'icon': Icons.group,
                            'key': 'SUB name'
                          },
                          {
                            'title': 'Site owner',
                            'icon': Icons.person,
                            'key': 'Site Owner'
                          },
                          {
                            'title': 'Co-located',
                            'icon': Icons.merge_type,
                            'key': 'Co-located'
                          },
                        ]),
                        _buildExpansionTile('Telecom', [
                          {
                            'title': 'Site severity',
                            'icon': Icons.warning,
                            'key': 'Site severity'
                          },
                          {
                            'title': 'No of related sites',
                            'icon': Icons.link,
                            'key': 'No of related site'
                          },
                          {
                            'title': 'No of (2G) Site Cells',
                            'icon': Icons.network_cell,
                            'key': 'No of (2G) Site Cells'
                          },
                          {
                            'title': 'No of (3G) Cells',
                            'icon': Icons.signal_wifi_4_bar,
                            'key': 'No of (3G) Cells'
                          },
                          {
                            'title': 'No. of LTE 1800 cells',
                            'icon': Icons.signal_cellular_alt_rounded,
                            'key': 'no. of LTE 1800 cells'
                          },
                          {
                            'title': 'No. of U900 cells',
                            'icon': Icons.signal_cellular_alt_2_bar_rounded,
                            'key': 'no. of U900 cells.'
                          },
                          {
                            'title': 'no. of LTE 2100 cells.',
                            'icon': Icons.signal_cellular_alt_1_bar_rounded,
                            'key': 'no. of LTE 2100 cells.'
                          },
                          {
                            'title': 'have co. site',
                            'icon': Icons.group,
                            'key': 'have co. site'
                          },
                          {
                            'title': 'No. of Co-site cell',
                            'icon': Icons.cell_tower,
                            'key': 'No. of Co-site cell'
                          },
                          {
                            'title': 'External Alarms',
                            'icon': Icons.alarm,
                            'key': 'External Alarms'
                          },
                          {
                            'title': 'TRM Type',
                            'icon': Icons.settings,
                            'key': 'TRM Type'
                          },
                          {
                            'title': 'RBS Type',
                            'icon': Icons.device_hub,
                            'key': 'RBS Type'
                          },
                          {
                            'title': 'Site indoor or outdoor',
                            'icon': Icons.home_work,
                            'key': 'Site indoor  or outdoor'
                          },
                          {
                            'title': 'No. of R.B.S Batteries',
                            'icon': Icons.battery_full,
                            'key': 'No. of R.B.S Batteries'
                          },
                          {
                            'title': 'Type of R.B.S Batteries',
                            'icon': Icons.battery_charging_full,
                            'key': 'Type of R.B.S Batteries'
                          },
                          {
                            'title': 'RBS batteries capacity',
                            'icon': Icons.battery_unknown_rounded,
                            'key': 'RBS batteries capacity'
                          },
                          {
                            'title': 'RBS batteries capacity',
                            'icon': Icons.battery_unknown_rounded,
                            'key': 'RBS batteries capacity'
                          },
                          {
                            'title': 'No Of TRM Battery',
                            'icon': Icons.battery_full,
                            'key': 'No Of TRM Battery'
                          },
                          {
                            'title': 'Type of TRM Battery',
                            'icon': Icons.battery_charging_full,
                            'key': 'Type of TRM Battery'
                          },
                          {
                            'title': 'Rectifier TRM capacity',
                            'icon': Icons.battery_unknown_rounded,
                            'key': 'Rectifier TRM capacity'
                          },
                          {
                            'title': 'Total No. Of Battery',
                            'icon': Icons.battery_std,
                            'key': 'Total No. Of Battery'
                          },
                          {
                            'title': 'RBS Configuration',
                            'icon': Icons.density_small_rounded,
                            'key': 'RBS Configuration'
                          },
                          {
                            'title': '900/1800/2100',
                            'icon': Icons.numbers_rounded,
                            'key': '900/1800/2100'
                          },
                          {
                            'title': '2G/3G/4G',
                            'icon': Icons.signal_cellular_no_sim_rounded,
                            'key': '2G/3G/4G'
                          },
                          {
                            'title': 'Fiber Node',
                            'icon': Icons.fiber_smart_record_rounded,
                            'key': 'Fiber Node'
                          },
                        ]),
                        _buildExpansionTile('Dates', [
                          {
                            'title': 'CONTRACTOR',
                            'icon': Icons.business_center,
                            'key': 'CONTRACTOR'
                          },
                          {
                            'title': 'On Air Date',
                            'icon': Icons.airplanemode_active,
                            'key': 'On Air Date'
                          },
                          {
                            'title': 'Off Air Date',
                            'icon': Icons.airplanemode_inactive,
                            'key': 'Off Air Date'
                          },
                          {
                            'title': 'PAC Date',
                            'icon': Icons.calendar_today,
                            'key': 'PAC Date'
                          },
                          {
                            'title': 'Handover Date',
                            'icon': Icons.transfer_within_a_station,
                            'key': 'Handover Date'
                          },
                          {
                            'title': 'Shutdown Date',
                            'icon': Icons.power_off,
                            'key': 'Shutdown Date'
                          },
                        ]),
                        _buildExpansionTile('Site Management', [
                          {
                            'title': 'Site type',
                            'icon': Icons.info_outline,
                            'key': 'Site type'
                          },
                          {
                            'title': 'Tower height',
                            'icon': Icons.height,
                            'key': 'Tower height'
                          },
                          {
                            'title': 'Address or GPS N',
                            'icon': Icons.navigation,
                            'key': 'Address or GPS     N'
                          },
                          {
                            'title': 'Address or GPS E',
                            'icon': Icons.navigation_outlined,
                            'key': 'Address or GPS    E'
                          },
                          {
                            'title': 'Distance from main office',
                            'icon': Icons.social_distance_rounded,
                            'key': 'Distance to site from main office (Km)'
                          },
                          {
                            'title': 'Distance from Sub office',
                            'icon': Icons.connect_without_contact_rounded,
                            'key': 'Distance to site from Sub office'
                          },
                          {
                            'title': 'Commercial Water source',
                            'icon': Icons.water_rounded,
                            'key': 'Commercial Water source'
                          },
                          {
                            'title': 'Sunshed for RBS',
                            'icon': Icons.wb_shade_rounded,
                            'key': 'Sunshed for RBS'
                          },
                          {
                            'title': 'Sunshed for Gen',
                            'icon': Icons.wb_shade_rounded,
                            'key': 'Sunshed for Gen'
                          },
                          {
                            'title': 'External ladder',
                            'icon': Icons.pan_tool_sharp,
                            'key': 'External ladder'
                          },
                          //=======================
                          {
                            'title': 'Towers ladder',
                            'icon': Icons.do_not_step_outlined,
                            'key': 'Towers ladder'
                          },
                          {
                            'title': 'Guard/owner',
                            'icon': Icons.person_outline_rounded,
                            'key': 'Guard / owner'
                          },
                          {
                            'title': 'Telephone 1',
                            'icon': Icons.phone,
                            'key': 'Telephone'
                          },
                          {
                            'title': 'Telephone 2',
                            'icon': Icons.phone,
                            'key': 'Telephone 1'
                          },
                          {
                            'title': 'Telephone 3',
                            'icon': Icons.phone,
                            'key': 'Telephone 2'
                          },
                        ]),
                        _buildExpansionTile('Electrical', [
                          {
                            'title': 'ATS Available',
                            'icon': Icons.power,
                            'key': "ATS Availed"
                          },
                          {
                            'title': 'ATS designed by',
                            'icon': Icons.design_services,
                            'key': "ATS designed by"
                          },
                          {
                            'title': 'System Type',
                            'icon': Icons.settings_system_daydream,
                            'key': "System Type"
                          },
                          {
                            'title': 'Brand',
                            'icon': Icons.branding_watermark,
                            'key': "Brand"
                          },
                          {
                            'title': 'Module Type',
                            'icon': Icons.featured_play_list_outlined,
                            'key': "Module Type"
                          },
                          {
                            'title': 'No. of Modules',
                            'icon': Icons.grid_view,
                            'key': "No. of Modules"
                          },
                          {
                            'title': 'Beacon light Available',
                            'icon': Icons.lightbulb_outline,
                            'key': "Becon light availed"
                          },
                          {
                            'title': 'Notes',
                            'icon': Icons.note_alt,
                            'key': "Notes"
                          },
                          {
                            'title': 'Commercial power',
                            'icon': Icons.power_outlined,
                            'key': "Commercial power"
                          },
                          {
                            'title': 'Commercial Power source',
                            'icon': Icons.emoji_transportation_rounded,
                            'key': "Commercial Power source"
                          },
                          {
                            'title': 'Date Of Connecting to CP',
                            'icon': Icons.date_range_rounded,
                            'key': "Date Of Conecting to CP"
                          },
                          {
                            'title': 'CP meter',
                            'icon': Icons.numbers_rounded,
                            'key': "CP meter"
                          },
                          {
                            'title': 'SP smart meter',
                            'icon': Icons.smart_button_rounded,
                            'key': "SP smart meter"
                          },
                          {
                            'title': 'Single phase or three phase',
                            'icon': Icons.format_line_spacing_rounded,
                            'key': "Single phase or three phase"
                          },
                        ]),
                        _buildExpansionTile('Fuel', [
                          {
                            'title': "Number of fuel tanks",
                            "icon": Icons.local_gas_station,
                            "key": "Number of fuel tanks"
                          },
                          {
                            'title': "Total Fuel Tank Capacity",
                            "icon": Icons.rectangle,
                            "key": "Total Fuel Tank Capacity"
                          },
                          {
                            'title': "1st Fuel Tank Shape",
                            "icon": Icons.gas_meter,
                            "key": "1st Fuel Tank Shape"
                          },
                          {
                            'title': "1st Fuel Tank Capacity",
                            "icon": Icons.shape_line,
                            "key": "1st Fuel Tank Capacity"
                          },
                          {
                            'title': "2nd Fuel Tank Shape",
                            "icon": Icons.gas_meter,
                            "key": "2nd Fuel Tank Shape"
                          },
                          {
                            'title': "2nd Fuel Tank Capacity",
                            "icon": Icons.shape_line,
                            "key": "2nd Fuel Tank Capacity"
                          },
                          {
                            'title': "3rd Fuel Tank Shapee",
                            "icon": Icons.gas_meter,
                            "key": "3rd Fuel Tank Shape"
                          },
                          {
                            'title': "3rd Fuel Tank Capacity",
                            "icon": Icons.shape_line,
                            "key": "3rd Fuel Tank Capacity"
                          },
                        ]),
                        _buildExpansionTile('Generators', [
                          {
                            'title': 'No.Of Generator',
                            "icon": Icons.numbers_rounded,
                            "key": "No.Of Generator"
                          },
                          {
                            'title': 'Gen No',
                            "icon": Icons.looks_one_rounded,
                            "key": "Gen No 1"
                          },
                          {
                            'title': 'Gen. serial number',
                            "icon": Icons.password_rounded,
                            "key": "Gen. serial number 1"
                          },
                          {
                            'title': 'Alt.s/n',
                            "icon": Icons.password_rounded,
                            "key": "Alt.s/n 1"
                          },
                          {
                            'title': 'Alternator Type',
                            "icon": Icons.type_specimen_rounded,
                            "key": "Alternator Type 1"
                          },
                          {
                            'title': 'GBrand',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "GBrand 1"
                          },
                          {
                            'title': 'Engine Serial number',
                            "icon": Icons.password_rounded,
                            "key": "Engine Serial number 1"
                          },
                          {
                            'title': 'Engine Type',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine Type 1"
                          },
                          {
                            'title': 'Engine model',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine model 1"
                          },
                          {
                            'title': 'Capacity(KVA)',
                            "icon": Icons.reduce_capacity_rounded,
                            "key": "Capacity(KVA) 1"
                          },
                          {
                            'title': 'Engine Part List',
                            "icon": Icons.confirmation_num_rounded,
                            "key": "Engine Part List 1"
                          },
                          {
                            'title': 'Gen Model',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Gen Model 1"
                          },
                          {
                            'title': 'Gen charger available',
                            "icon": Icons.power_input_rounded,
                            "key": "Gen charger available 1"
                          },
                          {
                            'title': 'Engine Part List',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine Part List 1"
                          },
                          {
                            'title': 'Gen.Controller Type',
                            "icon": Icons.credit_card_rounded,
                            "key": "Gen.Controller Type 1"
                          },
                          {
                            'title': 'Gen No',
                            "icon": Icons.looks_two_rounded,
                            "key": "Gen No 2"
                          },
                          {
                            'title': 'Gen. serial number',
                            "icon": Icons.password_rounded,
                            "key": "Gen. serial number 2"
                          },
                          {
                            'title': 'Alt.s/n',
                            "icon": Icons.password_rounded,
                            "key": "Alt.s/n 2"
                          },
                          {
                            'title': 'Alternator Type',
                            "icon": Icons.type_specimen_rounded,
                            "key": "Alternator Type 2"
                          },
                          {
                            'title': 'GBrand',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "GBrand 2"
                          },
                          {
                            'title': 'Engine Serial number',
                            "icon": Icons.password_rounded,
                            "key": "Engine Serial number 2"
                          },
                          {
                            'title': 'Engine Type',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine Type 2"
                          },
                          {
                            'title': 'Engine model',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine model 2"
                          },
                          {
                            'title': 'Capacity(KVA)',
                            "icon": Icons.reduce_capacity_rounded,
                            "key": "Capacity (KVA) 2"
                          },
                          {
                            'title': 'Engine Part List',
                            "icon": Icons.confirmation_num_rounded,
                            "key": "Engine Part List 2"
                          },
                          {
                            'title': 'Gen Model',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Gen Model 2"
                          },
                          {
                            'title': 'Gen charger available',
                            "icon": Icons.power_input_rounded,
                            "key": "Gen charger available 2"
                          },
                          {
                            'title': 'Engine Part List',
                            "icon": Icons.branding_watermark_rounded,
                            "key": "Engine Part List 2"
                          },
                          {
                            'title': 'Gen.Controller Type',
                            "icon": Icons.credit_card_rounded,
                            "key": "Gen.Controller Type 2"
                          },
                        ]),
                        _buildExpansionTile('AC', [
                          {
                            'title': 'No. of AC',
                            "icon": Icons.ac_unit,
                            "key": "No. of AC"
                          },
                          {
                            'title': 'Site indoor or outdoor',
                            'icon': Icons.home_work,
                            'key': 'Site indoor  or outdoor'
                          },
                          {
                            'title': 'AC 1',
                            "icon": Icons.air_outlined,
                            "key": '1'
                          },
                          {
                            'title': 'Outdoor S/N',
                            "icon": Icons.looks_one_rounded,
                            "key": "AC. serial number Outdoor 1"
                          },
                          {
                            'title': 'Indoor S/N',
                            "icon": Icons.looks_one_rounded,
                            "key": "AC.serial number Indoor 1"
                          },
                          {
                            'title': 'ACBrand',
                            "icon": Icons.looks_one_rounded,
                            "key": "ACBrand 1"
                          },
                          {
                            'title': 'BTU',
                            "icon": Icons.looks_one_rounded,
                            "key": "BTU 1"
                          },
                          {
                            'title': 'AC model',
                            "icon": Icons.looks_one_rounded,
                            "key": "AC model 1"
                          },
                          {
                            'title': 'AC 2',
                            "icon": Icons.air_outlined,
                            "key": '2'
                          },
                          {
                            'title': 'Outdoor S/N',
                            "icon": Icons.looks_two_rounded,
                            "key": "AC. serial number Outdoor 2"
                          },
                          {
                            'title': 'Indoor S/N',
                            "icon": Icons.looks_two_rounded,
                            "key": "AC.serial number Indoor 2"
                          },
                          {
                            'title': 'ACBrand',
                            "icon": Icons.looks_two_rounded,
                            "key": "Brand 2"
                          },
                          {
                            'title': 'BTU',
                            "icon": Icons.looks_two_rounded,
                            "key": "BTU 2"
                          },
                          {
                            'title': 'AC model',
                            "icon": Icons.looks_two_rounded,
                            "key": "AC model 2"
                          },
                          {
                            'title': 'AC 3',
                            "icon": Icons.air_outlined,
                            "key": '3'
                          },
                          {
                            'title': 'Outdoor S/N',
                            "icon": Icons.looks_3_rounded,
                            "key": "AC. serial number Outdoor 3"
                          },
                          {
                            'title': 'Indoor S/N',
                            "icon": Icons.looks_3_rounded,
                            "key": "AC.serial number Indoor 3"
                          },
                          {
                            'title': 'ACBrand',
                            "icon": Icons.looks_3_rounded,
                            "key": "ACBrand 3"
                          },
                          {
                            'title': 'BTU',
                            "icon": Icons.looks_3_rounded,
                            "key": "BTU 3"
                          },
                          {
                            'title': 'AC model',
                            "icon": Icons.looks_3_rounded,
                            "key": "AC model 3"
                          },
                        ]),
                      ] else ...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: GestureDetector(
                                onTap: () => showSearchableDropdown(
                                      context,
                                      _siteNames,
                                      (selected) {
                                        setState(() {
                                          _updateSelectedSiteData(selected);
                                        });
                                      },
                                      _searchController,
                                    ),
                                child: Text(
                                  'Select a Site ...',
                                  style: Theme.of(context).textTheme.titleLarge,
                                )),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
