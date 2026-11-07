import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crop_disease_info.dart';

class DiseaseKnowledgeRepository {
  Map<String, CropDiseaseInfo> _cache = {};
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/knowledge/diseases.json');
      final Map<String, dynamic> rawMap = json.decode(jsonString) as Map<String, dynamic>;
      final Map<String, CropDiseaseInfo> parsed = {};

      rawMap.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsed[key] = CropDiseaseInfo.fromJson(key, val);
        }
      });

      _cache = parsed;
      _isLoaded = true;
    } catch (e) {
      // Fallback empty cache
      _cache = {};
    }
  }

  Future<CropDiseaseInfo> getInfo(String key) async {
    if (!_isLoaded) await init();

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Try finding by crop/disease if key format has minor variations
    final cleanKey = key.trim().toLowerCase();
    for (final entry in _cache.entries) {
      if (entry.key.toLowerCase() == cleanKey) {
        return entry.value;
      }
    }

    // Fallback to humanized label when key is missing in diseases.json
    return CropDiseaseInfo.fallback(key);
  }

  Future<List<CropDiseaseInfo>> getAll() async {
    if (!_isLoaded) await init();
    return _cache.values.toList();
  }

  Future<List<CropDiseaseInfo>> getByCrop(String crop) async {
    if (!_isLoaded) await init();
    final lowerCrop = crop.toLowerCase().trim();
    return _cache.values
        .where((d) => d.crop.toLowerCase().trim() == lowerCrop)
        .toList();
  }

  Future<List<CropDiseaseInfo>> search(String query, bool isBangla) async {
    if (!_isLoaded) await init();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _cache.values.toList();

    return _cache.values.where((d) {
      final cropName = d.getCropName(isBangla).toLowerCase();
      final diseaseName = d.getDiseaseName(isBangla).toLowerCase();
      final desc = d.getDescription(isBangla).toLowerCase();
      final key = d.key.toLowerCase();
      return cropName.contains(q) ||
          diseaseName.contains(q) ||
          desc.contains(q) ||
          key.contains(q);
    }).toList();
  }
}

final diseaseKnowledgeRepositoryProvider =
    Provider<DiseaseKnowledgeRepository>((ref) {
  final repo = DiseaseKnowledgeRepository();
  repo.init();
  return repo;
});
