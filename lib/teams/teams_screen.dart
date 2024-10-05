import 'package:power_diyala/teams/teams_table_helper.dart';
import 'package:power_diyala/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:logger/logger.dart';

class TeamsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const TeamsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  TeamsScreenState createState() => TeamsScreenState();
}

class TeamsScreenState extends State<TeamsScreen> {
  DateTime selectedDay = DateTime.now();
  List<Map<String, dynamic>>? _data;
  final Logger logger = Logger();

  // Cache to store events for each date
  final Map<DateTime, List<Map<String, dynamic>>> _eventsCache = {};
  // Declare a variable for the calendar format
  CalendarFormat _calendarFormat = CalendarFormat.month; // Default format

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(); // Call your data loading function
    });
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadTeamData();
      logger.i("Loaded data: $data");

      if (mounted) {
        setState(() {
          _data = data;
          _cacheEvents();
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

  void _cacheEvents() {
    for (var team in _data ?? []) {
      String? teamDateString =
          team['Date']; // Ensure this matches your data structure
      if (teamDateString != null) {
        DateTime teamDate = Teams.parseDate(teamDateString);
        // Add event to cache
        _eventsCache.putIfAbsent(teamDate, () => []).add(team);
      }
    }
  }

  List<Map<String, dynamic>> _filterTeamsByDate(DateTime selectedDate) {
    logger.i("Filtering teams for selected date: $selectedDate");

    DateTime localSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Return the cached events for the selected date
    return _eventsCache[localSelectedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Team Calendar',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: _buildEventList(selectedDay),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),

      focusedDay: selectedDay,
      currentDay: selectedDay,
      calendarFormat: _calendarFormat, // Use the calendar format variable
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
        });
      },
      onFormatChanged: (format) {
        // Handle format changes
        setState(() {
          _calendarFormat = format; // Update the calendar format variable
        });
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle:
            TextStyle(color: Colors.blue), // Color for weekdays (Sun-Thu)
        weekendStyle:
            TextStyle(color: Colors.red), // Color for weekends (Fri-Sat)
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) => _buildDayCell(date),
        dowBuilder: (context, day) {
          // Display weekday names
          final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

          return Center(
            child: Text(
              weekDays[day.weekday % 7], // Get the name from the list
              style: TextStyle(
                color: day.weekday == DateTime.friday ||
                        day.weekday == DateTime.saturday
                    ? Colors.red
                    : Colors.blue, // Color based on weekend or weekday
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    List<Map<String, dynamic>> events = _filterTeamsByDate(date);

    return Container(
      margin: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          // Day number
          Text(
            '${date.day}',
            style: TextStyle(
              fontWeight:
                  events.isNotEmpty ? FontWeight.bold : FontWeight.normal,
              color: events.isNotEmpty
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.amber
                      : Colors.blueAccent)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          // Dots for events
          if (events.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                events.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  width: 6.0, // Diameter of the dot
                  height: 6.0, // Diameter of the dot
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey, // Color of the dot
                    shape: BoxShape.circle, // Make it circular
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventList(DateTime day) {
    logger.i("Selected Day: $day");

    List<Map<String, dynamic>> filteredTeams = _filterTeamsByDate(day);

    if (filteredTeams.isEmpty) {
      logger.w("No events found for this day.");
      return const Center(child: Text('No events for this day'));
    }

    return ListView.builder(
      itemCount: filteredTeams.length,
      itemBuilder: (context, index) {
        return _buildTeamCard(filteredTeams[index]);
      },
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${team['Region']}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${team['Sites']}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Power Team:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent)),
                    Text('${team['P_Eng'] ?? "N/A"}',
                        style: const TextStyle(fontSize: 14)),
                    Text('${team['G_Tech'] ?? "N/A"}',
                        style: const TextStyle(fontSize: 14)),
                    Text('${team['E_Tech'] ?? "N/A"}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Telecom Team:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                    Text('${team['T_Eng'] ?? "N/A"}',
                        style: const TextStyle(fontSize: 14)),
                    Text('${team['T_Tech'] ?? "N/A"}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
