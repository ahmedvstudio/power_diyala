import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:path/path.dart' as path;
import 'package:power_diyala/settings/theme_control.dart';
import 'package:simple_icons/simple_icons.dart';

class EmailSender extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;
  const EmailSender(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  EmailSenderState createState() => EmailSenderState();
}

class EmailSenderState extends State<EmailSender> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  final List<String> _attachments = [];
  List<Map<String, dynamic>>? _emailsData;
  List<String> _toNames = [];
  final List<String> _toEmail = [];
  final List<String> _ccEmail = [];
  final TextEditingController _searchController = TextEditingController();
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _subjectController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFromManager();
    });
  }

  Future<void> _loadDataFromManager() async {
    try {
      final dataManager = DataManager();
      _emailsData = dataManager.getEmailsData();
      _toNames =
          _emailsData?.map((item) => item['Name'] as String).toList() ?? [];
      logger.i("Loaded Email data: $_emailsData");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _updateToEmailData(String name) {
    final selectedEmail =
        _emailsData?.firstWhere((item) => item['Name'] == name);
    if (selectedEmail != null) {
      setState(() {
        // Add email if it's not already in the list
        String email = selectedEmail['Email'];
        if (!_toEmail.contains(email)) {
          _toEmail.add(email);
        }
        // Update the _toController to show all selected emails
        _toController.text = _toEmail.join(', ');
      });
    }
  }

  void _updateCCEmailData(String name) {
    final selectedEmail =
        _emailsData?.firstWhere((item) => item['Name'] == name);
    if (selectedEmail != null) {
      setState(() {
        // Add email if it's not already in the list
        String email = selectedEmail['Email'];
        if (!_ccEmail.contains(email)) {
          _ccEmail.add(email);
        }
        // Update the _toController to show all selected emails
        _toController.text = _ccEmail.join(', ');
      });
    }
  }

  Future<void> send() async {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Theme.of(context).cardColor,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 120,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const Column(
                            children: [
                              Icon(Icons.task_alt_rounded,
                                  color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'All Done',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Would you like to send the email',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: const Text(
                                'Send',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      // Check if the user confirmed
      if (confirmed == true) {
        final Email email = Email(
          subject: _subjectController.text,
          recipients: _toEmail,
          cc: _ccEmail,
          attachmentPaths: _attachments,
        );

        String platformResponse;

        try {
          await FlutterEmailSender.send(email);
          platformResponse = 'success';
        } catch (error) {
          logger.e(error);
          platformResponse = error.toString();
        }

        if (!mounted) return;
        logger.i(platformResponse);
        Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Email Assist', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_outlined),
            style: Theme.of(context).iconButtonTheme.style,
            onSelected: (int selected) {
              if (selected == 1) {
                //
                _toEmail.clear();
                _ccEmail.clear();

                // Update the text controllers
                _toController.clear();
                _ccController.clear();

                // Define a list of PM emails
                List<String> pmToEmails =
                    dotenv.env['PM_TO_EMAILS']?.split(',') ?? [];
                List<String> pmCcEmails =
                    dotenv.env['PM_CC_EMAILS']?.split(',') ?? [];

                setState(() {
                  // Subject
                  _subjectController.text =
                      'PM Sheets ${DateTime.now().day}/${DateTime.now().month}';
                  // Add PM emails to TO list
                  for (var email in pmToEmails) {
                    if (!_toEmail.contains(email)) {
                      _toEmail.add(email);
                    }
                  }

                  // Add PM emails to CC list
                  for (var email in pmCcEmails) {
                    if (!_ccEmail.contains(email)) {
                      _ccEmail.add(email);
                    }
                  }

                  // Update the text controllers
                  _toController.text =
                      _toEmail.join(', '); // Update the To field
                  _ccController.text =
                      _ccEmail.join(', '); // Update the CC field
                });
              } else if (selected == 0) {
                _toEmail.clear();
                _ccEmail.clear();

                // Update the text controllers
                _toController.clear();
                _ccController.clear();
                // Handle CM emails if needed
                List<String> cmToEmails =
                    dotenv.env['CM_TO_EMAILS']?.split(',') ?? [];
                List<String> cmCcEmails =
                    dotenv.env['CM_CC_EMAILS']?.split(',') ?? [];

                setState(() {
                  // Subject
                  _subjectController.text =
                      'CM Sheet ${DateTime.now().day}/${DateTime.now().month}';

                  // Add CM emails to TO list
                  for (var email in cmToEmails) {
                    if (!_toEmail.contains(email)) {
                      _toEmail.add(email);
                    }
                  }

                  // Add CM emails to CC list
                  for (var email in cmCcEmails) {
                    if (!_ccEmail.contains(email)) {
                      _ccEmail.add(email);
                    }
                  }

                  // Update the text controllers
                  _toController.text =
                      _toEmail.join(', '); // Update the To field
                  _ccController.text =
                      _ccEmail.join(', '); // Update the CC field
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text('PM emails'),
              ),
              const PopupMenuItem<int>(
                value: 0,
                child: Text('CM emails'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject:',
                      labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*Required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 1.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 'To' label and icon to open the dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "To:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => showSearchableDropdown(
                              context,
                              _toNames,
                              (selected) {
                                setState(() {
                                  _updateToEmailData(selected);
                                });
                              },
                              _searchController,
                            ),
                            child: const Icon(
                              Icons.group_add_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_toEmail.isNotEmpty)
                        Column(
                          children: _toEmail
                              .map(
                                (email) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _toEmail.remove(email);
                                      _toController.text = _toEmail.join(', ');
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.email,
                                            color: Colors.blue.shade700,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        AutoSizeText(
                                          email,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 8),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No recipients added",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 1.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "CC:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => showSearchableDropdown(
                              context,
                              _toNames,
                              (selected) {
                                setState(() {
                                  _updateCCEmailData(selected);
                                });
                              },
                              _searchController,
                            ),
                            child: const Icon(
                              Icons.group_add_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Display selected CC email addresses
                      if (_ccEmail.isNotEmpty)
                        Column(
                          children: _ccEmail
                              .map(
                                (email) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _ccEmail.remove(email);
                                      _ccController.text = _ccEmail.join(', ');
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.email,
                                            color: Colors.blue.shade700,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        AutoSizeText(
                                          email,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No CC recipients added",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title for attachments section
                      const Center(
                        child: Text(
                          "Attachments:",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_attachments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No attachments added.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        )
                      else
                        ..._attachments.map(
                          (attachment) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: <Widget>[
                                // File name display
                                Expanded(
                                  child: Text(
                                    path.basename(attachment),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeAttachment(
                                      _attachments.indexOf(attachment)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: send,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(Icons.send),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the current file path
      String originalPath = pickedFile.path;

      // Get the directory of the original file
      String dir = path.dirname(originalPath);

      // Show the rename dialog
      String? newName = await _promptForNewName();

      // If a new name was provided, rename the file
      if (newName != null && newName.isNotEmpty) {
        String newFilePath =
            path.join(dir, "$newName.jpg"); // Ensure it has a .jpg extension

        // Rename the file
        File originalFile = File(originalPath);
        try {
          await originalFile.rename(newFilePath);
          if (mounted) {
            setState(() {
              _attachments
                  .add(newFilePath); // Add the new file path to attachments
              logger.i('$newName.jpg');
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error renaming file: $e");
          }
          // Optionally show a snackbar or alert to inform the user of the error
          _showSnackbar('Error renaming file: ${e.toString()}');
        }
      }
    }
  }

  Future<String?> _promptForNewName() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).cardColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const Column(
                          children: [
                            Icon(Icons.edit_rounded,
                                color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Rename Image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Enter new name',
                          labelStyle: TextStyle(
                            color:
                                ThemeControl.errorColor.withValues(alpha: 0.8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 18.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (nameController.text.isNotEmpty) {
                              Navigator.of(context)
                                  .pop(nameController.text.trim());
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: const Text('OK',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _openSheetPicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        String fileName = path.basename(filePath); // Extract the file name

        // Check if the file name is already in the list
        bool isDuplicate = _attachments
            .any((attachment) => path.basename(attachment) == fileName);

        if (!isDuplicate) {
          setState(() {
            _attachments.add(filePath);
            logger.i('File attached: $filePath');
          });
        } else {
          _showSnackbar('This file has already been added.');
        }
      }
    } catch (e) {
      _showSnackbar('Error picking file: ${e.toString()}');
      logger.e(e);
    }
  }

  void _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        String fileName = path.basename(filePath); // Extract the file name

        // Check if the file name is already in the list
        bool isDuplicate = _attachments
            .any((attachment) => path.basename(attachment) == fileName);

        if (!isDuplicate) {
          setState(() {
            _attachments.add(filePath);
            logger.i('File attached: $filePath');
          });
        } else {
          _showSnackbar('This file has already been added.');
        }
      }
    } catch (e) {
      _showSnackbar('Error picking file: ${e.toString()}');
      logger.e(e);
    }
  }

  BottomAppBar _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Theme.of(context).appBarTheme.foregroundColor,
      height: 50,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(
              SimpleIcons.googlesheets,
              size: 20,
            ),
            onPressed: _openSheetPicker,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'attach spreadsheet',
          ),
          IconButton(
            icon: const Icon(
              Icons.image_rounded,
              size: 25,
            ),
            onPressed: _openImagePicker,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'attach image',
          ),
          IconButton(
            icon: const Icon(
              Icons.attach_file_rounded,
              size: 20,
            ),
            onPressed: _openFilePicker,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'attach file',
          ),
        ],
      ),
    );
  }
}
