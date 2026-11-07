import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/history_scan.dart';

class HistoryRepository {
  static const String boxName = 'cropdoc_history_scans';
  Box<String>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<String>(boxName);
  }

  List<HistoryScan> getAllScans() {
    if (_box == null || !_box!.isOpen) return [];
    final List<HistoryScan> list = [];
    for (var i = 0; i < _box!.length; i++) {
      final raw = _box!.getAt(i);
      if (raw != null) {
        try {
          final map = json.decode(raw) as Map<String, dynamic>;
          list.add(HistoryScan.fromJson(map));
        } catch (_) {
          // ignore corrupted single entry
        }
      }
    }
    // Sort newest first
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> saveScan(HistoryScan scan) async {
    if (_box == null || !_box!.isOpen) await init();
    final jsonStr = json.encode(scan.toJson());
    await _box!.put(scan.id, jsonStr);
  }

  Future<void> deleteScan(String id) async {
    if (_box == null || !_box!.isOpen) await init();
    await _box!.delete(id);
  }

  Future<void> clearAll() async {
    if (_box == null || !_box!.isOpen) await init();
    await _box!.clear();
  }

  Future<void> updateScan(HistoryScan updated) async {
    if (_box == null || !_box!.isOpen) await init();
    final jsonStr = json.encode(updated.toJson());
    await _box!.put(updated.id, jsonStr);
  }

  Future<void> reportScanWrong(String id, String? comment) async {
    if (_box == null || !_box!.isOpen) await init();
    final raw = _box!.get(id);
    if (raw != null) {
      final map = json.decode(raw) as Map<String, dynamic>;
      final scan = HistoryScan.fromJson(map);
      final updated = scan.copyWith(
        isReportedWrong: true,
        userFeedbackComment: comment,
      );
      await updateScan(updated);
    }
  }

  Future<void> exportCsvAndShare() async {
    final scans = getAllScans();
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Timestamp,Crop,Disease,Confidence,Status,IsReportedWrong,FeedbackComment');

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final s in scans) {
      final dateStr = dateFormat.format(s.timestamp);
      final confStr = (s.confidence * 100).toStringAsFixed(1);
      final comment = (s.userFeedbackComment ?? '').replaceAll('"', '""');
      buffer.writeln(
        '"${s.id}","$dateStr","${s.crop}","${s.disease}","$confStr%","${s.status.toApiString()}","${s.isReportedWrong}","$comment"',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/cropdoc_scans_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'CropDoc Scan History Export',
      text: 'Exported ${scans.length} diagnostic scan entries from CropDoc.',
    );
  }
}

class HistoryStateNotifier extends StateNotifier<List<HistoryScan>> {
  final HistoryRepository _repository;

  HistoryStateNotifier(this._repository) : super([]) {
    load();
  }

  Future<void> load() async {
    await _repository.init();
    state = _repository.getAllScans();
  }

  Future<void> addScan(HistoryScan scan) async {
    await _repository.saveScan(scan);
    state = _repository.getAllScans();
  }

  Future<void> deleteScan(String id) async {
    await _repository.deleteScan(id);
    state = _repository.getAllScans();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    state = [];
  }

  Future<void> markScanWrong(String id, String? comment) async {
    await _repository.reportScanWrong(id, comment);
    state = _repository.getAllScans();
  }

  Future<void> exportCsv() async {
    await _repository.exportCsvAndShare();
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyListProvider =
    StateNotifierProvider<HistoryStateNotifier, List<HistoryScan>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryStateNotifier(repo);
});
