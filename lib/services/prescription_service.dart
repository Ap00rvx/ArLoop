import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class PrescriptionItem {
  final String id;
  final String imagePath;
  final String name;
  final DateTime uploadedAt;
  final String? notes;

  PrescriptionItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.uploadedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'name': name,
    'uploadedAt': uploadedAt.toIso8601String(),
    'notes': notes,
  };

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      PrescriptionItem(
        id: json['id'],
        imagePath: json['imagePath'],
        name: json['name'],
        uploadedAt: DateTime.parse(json['uploadedAt']),
        notes: json['notes'],
      );
}

class PrescriptionService {
  static const _storage = FlutterSecureStorage();
  static const String _prescriptionsKey = 'prescription_items';

  // Singleton implementation
  PrescriptionService._privateConstructor();
  static final PrescriptionService _instance =
      PrescriptionService._privateConstructor();
  factory PrescriptionService() {
    return _instance;
  }

  // Get all prescriptions
  Future<List<PrescriptionItem>> getPrescriptions() async {
    try {
      final String? prescriptionsData = await _storage.read(
        key: _prescriptionsKey,
      );
      if (prescriptionsData == null) return [];

      final List<dynamic> prescriptionsJson = json.decode(prescriptionsData);
      return prescriptionsJson
          .map((item) => PrescriptionItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting prescriptions: $e');
      return [];
    }
  }

  // Save image to local storage and add prescription
  Future<PrescriptionItem?> savePrescription(
    String imagePath,
    String name, {
    String? notes,
  }) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String prescriptionsDir = '${appDocDir.path}/prescriptions';

      // Create prescriptions directory if it doesn't exist
      final Directory prescriptionDirectory = Directory(prescriptionsDir);
      if (!await prescriptionDirectory.exists()) {
        await prescriptionDirectory.create(recursive: true);
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = imagePath.split('.').last;
      final String fileName = 'prescription_$timestamp.$fileExtension';
      final String newPath = '$prescriptionsDir/$fileName';

      // Copy image to app directory
      final File originalFile = File(imagePath);
      final File newFile = await originalFile.copy(newPath);

      // Create prescription item
      final prescription = PrescriptionItem(
        id: timestamp,
        imagePath: newFile.path,
        name: name,
        uploadedAt: DateTime.now(),
        notes: notes,
      );

      // Save to storage
      await _addPrescriptionToStorage(prescription);

      return prescription;
    } catch (e) {
      print('Error saving prescription: $e');
      return null;
    }
  }

  // Add prescription to storage
  Future<void> _addPrescriptionToStorage(PrescriptionItem prescription) async {
    try {
      List<PrescriptionItem> prescriptions = await getPrescriptions();
      prescriptions.insert(
        0,
        prescription,
      ); // Add to beginning (most recent first)

      final String prescriptionsJson = json.encode(
        prescriptions.map((item) => item.toJson()).toList(),
      );
      await _storage.write(key: _prescriptionsKey, value: prescriptionsJson);
    } catch (e) {
      print('Error adding prescription to storage: $e');
    }
  }

  // Delete prescription
  Future<bool> deletePrescription(String prescriptionId) async {
    try {
      List<PrescriptionItem> prescriptions = await getPrescriptions();

      // Find prescription to delete
      final prescriptionToDelete = prescriptions.firstWhere(
        (item) => item.id == prescriptionId,
      );

      // Delete image file
      final File imageFile = File(prescriptionToDelete.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Remove from list
      prescriptions.removeWhere((item) => item.id == prescriptionId);

      // Save updated list
      final String prescriptionsJson = json.encode(
        prescriptions.map((item) => item.toJson()).toList(),
      );
      await _storage.write(key: _prescriptionsKey, value: prescriptionsJson);

      return true;
    } catch (e) {
      print('Error deleting prescription: $e');
      return false;
    }
  }

  // Update prescription notes
  Future<bool> updatePrescriptionNotes(
    String prescriptionId,
    String notes,
  ) async {
    try {
      List<PrescriptionItem> prescriptions = await getPrescriptions();

      // Find and update prescription
      final index = prescriptions.indexWhere(
        (item) => item.id == prescriptionId,
      );
      if (index != -1) {
        prescriptions[index] = PrescriptionItem(
          id: prescriptions[index].id,
          imagePath: prescriptions[index].imagePath,
          name: prescriptions[index].name,
          uploadedAt: prescriptions[index].uploadedAt,
          notes: notes,
        );

        // Save updated list
        final String prescriptionsJson = json.encode(
          prescriptions.map((item) => item.toJson()).toList(),
        );
        await _storage.write(key: _prescriptionsKey, value: prescriptionsJson);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating prescription notes: $e');
      return false;
    }
  }

  // Check if image file exists
  Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }

  // Clean up orphaned prescriptions (where image file doesn't exist)
  Future<void> cleanupOrphanedPrescriptions() async {
    try {
      List<PrescriptionItem> prescriptions = await getPrescriptions();
      List<PrescriptionItem> validPrescriptions = [];

      for (final prescription in prescriptions) {
        if (await imageExists(prescription.imagePath)) {
          validPrescriptions.add(prescription);
        }
      }

      // Save cleaned list if any were removed
      if (validPrescriptions.length != prescriptions.length) {
        final String prescriptionsJson = json.encode(
          validPrescriptions.map((item) => item.toJson()).toList(),
        );
        await _storage.write(key: _prescriptionsKey, value: prescriptionsJson);
      }
    } catch (e) {
      print('Error cleaning up prescriptions: $e');
    }
  }
}
