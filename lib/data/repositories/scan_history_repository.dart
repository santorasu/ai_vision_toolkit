import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/scan_history_model.dart';

class ScanHistoryRepository {
  static const String _boxName = 'scan_history';
  static const _uuid = Uuid();

  Box<ScanHistoryModel> get _box => Hive.box<ScanHistoryModel>(_boxName);

  /// Get all scan history records sorted by date descending
  List<ScanHistoryModel> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Search history by query string
  List<ScanHistoryModel> search(String query) {
    if (query.isEmpty) return getAll();
    final lowerQuery = query.toLowerCase();
    return getAll()
        .where(
          (item) =>
              item.result.toLowerCase().contains(lowerQuery) ||
              item.type.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Add a new scan result to history
  Future<void> add({
    required String type,
    required String result,
    String? imagePath,
  }) async {
    final item = ScanHistoryModel(
      id: _uuid.v4(),
      type: type,
      result: result,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
    await _box.put(item.id, item);
  }

  /// Delete a specific history item by id
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Clear all history
  Future<void> clearAll() async {
    await _box.clear();
  }
}
