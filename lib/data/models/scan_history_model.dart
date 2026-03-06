import 'package:hive/hive.dart';

part 'scan_history_model.g.dart';

@HiveType(typeId: 0)
class ScanHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'ocr', 'barcode', 'label', 'document', 'face', 'pose'

  @HiveField(2)
  final String result;

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  final DateTime createdAt;

  ScanHistoryModel({
    required this.id,
    required this.type,
    required this.result,
    this.imagePath,
    required this.createdAt,
  });
}

class ScanHistoryModelAdapter extends TypeAdapter<ScanHistoryModel> {
  @override
  final int typeId = 0;

  @override
  ScanHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryModel(
      id: fields[0] as String,
      type: fields[1] as String,
      result: fields[2] as String,
      imagePath: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
