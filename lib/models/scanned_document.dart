import 'package:json_annotation/json_annotation.dart';

part 'scanned_document.g.dart';

@JsonSerializable()
class ScannedDocument {
  final String id;
  final String title;
  final String text;
  final String folder;
  final List<String> tags;
  final DateTime timestamp;

  ScannedDocument({
    required this.id,
    required this.title,
    required this.text,
    required this.folder,
    required this.tags,
    required this.timestamp,
  });

  factory ScannedDocument.fromJson(Map<String, dynamic> json) =>
      _$ScannedDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedDocumentToJson(this);
}
