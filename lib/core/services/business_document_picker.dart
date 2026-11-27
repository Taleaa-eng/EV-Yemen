import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/business_document.dart';

class BusinessDocumentPicker {
  static const maxBytes = 5 * 1024 * 1024;

  static Future<BusinessDocument?> pick({required String folder}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.size > maxBytes) {
      throw const BusinessDocumentPickerException(
          'يجب ألا يتجاوز حجم الملف 5 MB.');
    }
    final sourcePath = file.path;
    if (sourcePath == null) {
      throw const BusinessDocumentPickerException('تعذّر قراءة الملف المختار.');
    }
    final appDocuments = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(
        '${appDocuments.path}${Platform.pathSeparator}business_documents${Platform.pathSeparator}$folder');
    await targetDirectory.create(recursive: true);
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final target = File(
        '${targetDirectory.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}_$safeName');
    await File(sourcePath).copy(target.path);
    return BusinessDocument(
        name: file.name, path: target.path, size: file.size);
  }
}

class BusinessDocumentPickerException implements Exception {
  const BusinessDocumentPickerException(this.message);
  final String message;
}
