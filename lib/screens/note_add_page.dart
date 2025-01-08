import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:power_diyala/data_helper/note_helper.dart';

class NoteAddPage extends StatefulWidget {
  final Map<String, dynamic> team;

  const NoteAddPage({super.key, required this.team});

  @override
  NoteAddPageState createState() => NoteAddPageState();
}

class NoteAddPageState extends State<NoteAddPage> {
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _controller = TextEditingController();
  Color selectedColor = Colors.teal;

  void _addComment(String comment) {
    setState(() {
      comments.add({
        'text': '${comments.length + 1}.$comment', // Prepend number
        'color': selectedColor,
      });
    });
    _controller.clear();
  }

  void _removeComment(int index) {
    setState(() {
      comments.removeAt(index);
      for (int i = 0; i < comments.length; i++) {
        comments[i]['text'] = '${i + 1}. ${comments[i]['text'].split('. ')[1]}';
      }
    });
  }

  void _changeCommentColor(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Color'),
          children: [
            _colorOption(Colors.grey, index),
            _colorOption(Colors.red, index),
            _colorOption(Colors.teal, index),
            _colorOption(Colors.blue, index),
            _colorOption(Colors.purple, index),
            _colorOption(Colors.orange, index),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(Color color, int index) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          comments[index]['color'] = color;
        });
        Navigator.of(context).pop(); // Close the dialog
      },
      child: Container(
        height: 50,
        width: 50,
        color: color,
      ),
    );
  }

  Future<void> _saveNote() async {
    final commentsString = comments
        .map((c) => '${c['text']}|${c['color'].value.toRadixString(16)}')
        .join('// ');
    final note = {
      'region': widget.team['Region'],
      'sites': widget.team['Sites'],
      'date': widget.team['Date'],
      'p_eng': widget.team['P_Eng'],
      't_eng': widget.team['T_Eng'],
      't_tech': widget.team['T_Tech'],
      'g_tech': widget.team['G_Tech'],
      'e_tech': widget.team['E_Tech'],
      'comments': commentsString,
    };
    await NoteHelper().insertNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Notes', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
              Navigator.of(context).pop();
            },
            tooltip: "Save",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${widget.team['Region'] ?? "N/A"}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('${widget.team['Date'] ?? "N/A"}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${widget.team['Sites'] ?? "N/A"}',
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
                            Text('${widget.team['P_Eng'] ?? "N/A"}',
                                style: const TextStyle(fontSize: 14)),
                            Text('${widget.team['G_Tech'] ?? "N/A"}',
                                style: const TextStyle(fontSize: 14)),
                            Text('${widget.team['E_Tech'] ?? "N/A"}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Telecom Team:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent)),
                            Text('${widget.team['T_Eng'] ?? "N/A"}',
                                style: const TextStyle(fontSize: 14)),
                            Text('${widget.team['T_Tech'] ?? "N/A"}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index]['text'],
                        style: TextStyle(
                            color: comments[index]['color']) // Set text color
                        ),
                    trailing: PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert_outlined),
                      onSelected: (int selected) {
                        if (selected == 0) {
                          _removeComment(index); // Call the delete function
                        } else if (selected == 1) {
                          _changeCommentColor(
                              index); // Call the change color function
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.color_lens_outlined,
                                  color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text('Change Color'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Add Notes:',
                      labelStyle: TextStyle(
                          color: ThemeControl.errorColor.withOpacity(0.8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 1.0),
                      ),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            _addComment(_controller.text);
                          }
                        },
                        icon: const Icon(Icons.insert_comment),
                        tooltip: 'add',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
