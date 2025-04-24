import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/scanned_document.dart';

class LocalDBService {
  static const String boxName = 'scanned_documents';
  
  // Initialize the database
  static Future<Box> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }
  
  // Save a document to the database
  static Future<void> saveDocument(ScannedDocument document) async {
    final box = await openBox();
    await box.put(document.id, jsonEncode(document.toJson()));
  }
  
  // Get all documents from the database
  static Future<List<ScannedDocument>> getAllDocuments() async {
    final box = await openBox();
    final List<ScannedDocument> documents = [];
    
    for (var key in box.keys) {
      final String? documentJson = box.get(key);
      if (documentJson != null) {
        final Map<String, dynamic> documentMap = jsonDecode(documentJson);
        documents.add(ScannedDocument.fromJson(documentMap));
      }
    }
    
    // Sort by timestamp (newest first)
    documents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return documents;
  }
  
  // Delete a document from the database
  static Future<void> deleteDocument(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
  
  // Update a document in the database
  static Future<void> updateDocument(ScannedDocument document) async {
    await saveDocument(document);
  }
  
  // Clear all documents from the database
  static Future<void> clearAll() async {
    final box = await openBox();
    await box.clear();
  }
  
  // Get all unique folders
  static Future<List<String>> getAllFolders() async {
    final documents = await getAllDocuments();
    final Set<String> folders = documents.map((doc) => doc.folder).toSet();
    return folders.toList();
  }
  
  // Get all unique tags
  static Future<List<String>> getAllTags() async {
    final documents = await getAllDocuments();
    final Set<String> tags = {};
    
    for (var doc in documents) {
      tags.addAll(doc.tags);
    }
    
    return tags.toList();
  }
}