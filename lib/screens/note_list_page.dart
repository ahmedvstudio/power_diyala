import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/data_helper/note_helper.dart';
import 'package:power_diyala/settings/notifications_services.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:power_diyala/widgets/detect_date_format.dart';

DateTime _scheduleTime = DateTime.now();

class NotesListPage extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const NotesListPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  NotesListPageState createState() => NotesListPageState();
}

class NotesListPageState extends State<NotesListPage> {
  late Future<List<Map<String, dynamic>>> notesFuture;
  bool _isSelected = false;
  int? _selectedIndex;

  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      notesFuture = NoteHelper().getNotes();
    });
  }

  Future<void> _deleteNote(int id) async {
    await NoteHelper().deleteNote(id);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onLongPress: () {
              LocalNotificationService().showNotification(
                id: 0,
                title: "Test Notification",
                body: 'it is working...',
                context: context,
              );
            },
            child:
                Text('Notes', style: Theme.of(context).textTheme.titleLarge)),
        actions: [
          IconButton(
            onPressed: () {
              LocalNotificationService().cancelAllNotification();
            },
            icon: const Icon(Icons.notifications_off_rounded),
            tooltip: 'Cancel all Alarms',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No Notes Available',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 16),
            ));
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final comments = _parseComments(note['comments']);
                bool isSelected = _isSelected &&
                    index == _selectedIndex; // Check if this card is selected

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 2),
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _isSelected = true;
                            _selectedIndex =
                                index; // Store the index of the selected card
                          });
                        },
                        onTap: () {
                          setState(() {
                            _isSelected = false;
                          });
                        },
                        child: Card(
                          surfaceTintColor: isSelected
                              ? Colors.yellow
                              : Theme.of(context).cardColor,
                          elevation: isSelected ? 5 : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff003952),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 12),
                                      width: 50,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              note['date'] != null
                                                  ? note['date'].split('/')[0]
                                                  : "N/A", // Day
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.yellow,
                                                  fontStyle: FontStyle.italic)),
                                          Text(
                                              note['date'] != null
                                                  ? note['date'].split('/')[1]
                                                  : "N/A", // Month
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                          Text(
                                              note['date'] != null
                                                  ? note['date'].split('/')[2]
                                                  : "N/A", // Year
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (note['p_eng'] != null)
                                          Text('${note['p_eng']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      letterSpacing: 1,
                                                      color: Colors.orange)),
                                        Text(
                                          '${note['sites'] ?? "N/A"}'
                                              .split("/")
                                              .map((site) => site.trim())
                                              .join('\n'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "Notes:",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 8,
                                  children: comments.map((comment) {
                                    return Chip(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: ThemeControl.errorColor
                                                .withValues(alpha: 0.3),
                                          )),
                                      label: Text(
                                        comment['text'],
                                        style: TextStyle(
                                          color: comment['color'],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black38
                                              : Colors.white38,
                                      shadowColor:
                                          Theme.of(context).shadowColor,
                                      padding: const EdgeInsets.all(0),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 15,
                        right: 35,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  showTitleActions: true,
                                  currentTime: parseDate(note['date']),
                                  onChanged: (date) => _scheduleTime = date,
                                  onConfirm: (date) {
                                    LocalNotificationService()
                                        .scheduleNotesNotification(
                                      id: note['id'],
                                      title: note['sites'],
                                      body: note['sites'],
                                      payLoad: note['id'].toString(),
                                      scheduledNotificationDateTime:
                                          _scheduleTime,
                                      summary: note['p_eng'] ?? note['region'],
                                      lines: _extractCommentTexts(
                                          note['comments']),
                                      context: context,
                                    );
                                  },
                                );
                                setState(() {
                                  _isSelected = false;
                                });
                              },
                              child: const Icon(
                                Icons.access_alarm_rounded,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                LocalNotificationService()
                                    .cancelNoteNotification(note['id']);
                                setState(() {
                                  _isSelected = false;
                                });
                              },
                              child: const Icon(
                                Icons.alarm_off_rounded,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _deleteNote(note['id']);
                                _isSelected = false;
                              },
                              child: const Icon(
                                Icons.remove_circle_outline_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  // Helper method to parse comments and colors
  List<Map<String, dynamic>> _parseComments(String commentsString) {
    List<Map<String, dynamic>> parsedComments = [];
    final commentsList = commentsString.split('// ');

    for (var comment in commentsList) {
      final parts = comment.split('|');
      if (parts.length == 2) {
        final text = parts[0];
        final colorHex = int.parse(parts[1], radix: 16);
        final color = Color(colorHex);

        parsedComments.add({'text': text, 'color': color});
      }
    }

    return parsedComments;
  }

  List<String> _extractCommentTexts(String commentsString) {
    final commentsList = commentsString.split('// ');
    final extractedComments = <String>[];

    for (var comment in commentsList) {
      final parts = comment.split('|');
      if (parts.length == 2) {
        extractedComments.add(parts[0]);
      }
    }

    return extractedComments;
  }
}
