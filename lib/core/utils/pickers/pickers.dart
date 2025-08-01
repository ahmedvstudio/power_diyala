import 'package:file_picker/file_picker.dart';

class VPickers {
  /// --> Pick file from device
  static Future<FilePickerResult?> pickFile() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
  }
}
