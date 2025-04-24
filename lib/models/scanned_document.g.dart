// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedDocument _$ScannedDocumentFromJson(Map<String, dynamic> json) =>
    ScannedDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      folder: json['folder'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ScannedDocumentToJson(ScannedDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.text,
      'folder': instance.folder,
      'tags': instance.tags,
      'timestamp': instance.timestamp.toIso8601String(),
    };
