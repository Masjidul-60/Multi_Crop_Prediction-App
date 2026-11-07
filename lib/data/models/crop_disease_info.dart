import '../../core/utils/string_extensions.dart';

class CropDiseaseInfo {
  final String key;
  final String crop;
  final String disease;
  final String cropNameBn;
  final String cropNameEn;
  final String diseaseNameBn;
  final String diseaseNameEn;
  final String descriptionBn;
  final String descriptionEn;
  final List<String> symptomsBn;
  final List<String> symptomsEn;
  final List<String> whatToDoBn;
  final List<String> whatToDoEn;

  const CropDiseaseInfo({
    required this.key,
    required this.crop,
    required this.disease,
    required this.cropNameBn,
    required this.cropNameEn,
    required this.diseaseNameBn,
    required this.diseaseNameEn,
    required this.descriptionBn,
    required this.descriptionEn,
    required this.symptomsBn,
    required this.symptomsEn,
    required this.whatToDoBn,
    required this.whatToDoEn,
  });

  String getCropName(bool isBangla) => isBangla ? cropNameBn : cropNameEn;
  String getDiseaseName(bool isBangla) => isBangla ? diseaseNameBn : diseaseNameEn;
  String getDescription(bool isBangla) => isBangla ? descriptionBn : descriptionEn;
  List<String> getSymptoms(bool isBangla) => isBangla ? symptomsBn : symptomsEn;
  List<String> getWhatToDo(bool isBangla) => isBangla ? whatToDoBn : whatToDoEn;

  factory CropDiseaseInfo.fromJson(String key, Map<String, dynamic> json) {
    return CropDiseaseInfo(
      key: key,
      crop: (json['crop'] ?? '').toString(),
      disease: (json['disease'] ?? '').toString(),
      cropNameBn: (json['crop_name_bn'] ?? '').toString(),
      cropNameEn: (json['crop_name_en'] ?? '').toString(),
      diseaseNameBn: (json['disease_name_bn'] ?? '').toString(),
      diseaseNameEn: (json['disease_name_en'] ?? '').toString(),
      descriptionBn: (json['description_bn'] ?? '').toString(),
      descriptionEn: (json['description_en'] ?? '').toString(),
      symptomsBn: (json['symptoms_bn'] as List?)?.map((e) => e.toString()).toList() ?? [],
      symptomsEn: (json['symptoms_en'] as List?)?.map((e) => e.toString()).toList() ?? [],
      whatToDoBn: (json['what_to_do_bn'] as List?)?.map((e) => e.toString()).toList() ?? [],
      whatToDoEn: (json['what_to_do_en'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Create a fallback info when a model key is not present in diseases.json
  factory CropDiseaseInfo.fallback(String key) {
    final parts = key.split('/');
    final crop = parts.isNotEmpty ? parts[0] : 'Crop';
    final disease = parts.length > 1 ? parts[1] : 'Condition';

    final cleanCrop = crop.replaceAll('_', ' ').capitalizeWords();
    final cleanDisease = disease.replaceAll('_', ' ').capitalizeWords();

    return CropDiseaseInfo(
      key: key,
      crop: crop,
      disease: disease,
      cropNameBn: cleanCrop,
      cropNameEn: cleanCrop,
      diseaseNameBn: cleanDisease,
      diseaseNameEn: cleanDisease,
      descriptionBn: 'এই রোগটির বিস্তারিত বিবরণ বর্তমানে উপলব্ধ নয়।',
      descriptionEn: 'Detailed knowledge database entry is currently unavailable for this condition.',
      symptomsBn: ['পাতা পর্যবেক্ষণ করে স্থানীয় কৃষি কর্মকর্তার পরামর্শ নিন।'],
      symptomsEn: ['Inspect foliage and consult local agricultural services for guidance.'],
      whatToDoBn: ['TODO: verify with an agronomist'],
      whatToDoEn: ['TODO: verify with an agronomist'],
    );
  }
}

