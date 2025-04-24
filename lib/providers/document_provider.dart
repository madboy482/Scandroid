import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/scanned_document.dart';
import '../services/local_db_service.dart';

class DocumentProvider extends ChangeNotifier {
  List<ScannedDocument> _documents = [];
  bool _isLoading = false;
  bool _initialized = false;
  List<String> _folders = ['General', 'Receipts', 'Notes', 'IDs'];
  String _currentFolder = 'All';
  String _searchQuery = '';

  List<ScannedDocument> get documents {
    if (_currentFolder == 'All' && _searchQuery.isEmpty) {
      return [..._documents];
    } else if (_currentFolder != 'All' && _searchQuery.isEmpty) {
      return _documents.where((doc) => doc.folder == _currentFolder).toList();
    } else if (_currentFolder == 'All' && _searchQuery.isNotEmpty) {
      return searchByText(_searchQuery);
    } else {
      return _documents
          .where((doc) => 
              doc.folder == _currentFolder && 
              doc.text.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  bool get isLoading => _isLoading;
  List<String> get folders => ['All', ..._folders];
  String get currentFolder => _currentFolder;
  String get searchQuery => _searchQuery;

  void setCurrentFolder(String folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Initialize documents from local storage
  Future<void> initDocuments() async {
    if (_initialized) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _documents = await LocalDBService.getAllDocuments();
      
      // Get all unique folders from documents
      final storedFolders = await LocalDBService.getAllFolders();
      for (var folder in storedFolders) {
        if (!_folders.contains(folder)) {
          _folders.add(folder);
        }
      }
      
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDocument({
    required String title,
    required String text,
    required String folder,
    required List<String> tags,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final newDoc = ScannedDocument(
        id: const Uuid().v4(),
        title: title,
        text: text,
        folder: folder,
        tags: tags,
        timestamp: DateTime.now(),
      );
      
      // Save to local storage
      await LocalDBService.saveDocument(newDoc);
      
      // Add to memory list
      _documents.add(newDoc);
      
      // Add new folder if it doesn't exist
      if (!_folders.contains(folder)) {
        _folders.add(folder);
      }
    } catch (e) {
      debugPrint('Error adding document: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeDocument(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Remove from local storage
      await LocalDBService.deleteDocument(id);
      
      // Remove from memory list
      _documents.removeWhere((doc) => doc.id == id);
    } catch (e) {
      debugPrint('Error removing document: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Clear local storage
      await LocalDBService.clearAll();
      
      // Clear memory list
      _documents.clear();
      _folders = ['General', 'Receipts', 'Notes', 'IDs']; // Reset to default folders
    } catch (e) {
      debugPrint('Error clearing documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ScannedDocument> getByFolder(String folderName) {
    return _documents.where((doc) => doc.folder == folderName).toList();
  }

  List<ScannedDocument> searchByText(String query) {
    if (query.isEmpty) return [..._documents];
    return _documents
        .where((doc) => 
            doc.text.toLowerCase().contains(query.toLowerCase()) ||
            doc.title.toLowerCase().contains(query.toLowerCase()) ||
            doc.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  List<ScannedDocument> searchByTag(String tag) {
    return _documents
        .where((doc) => doc.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
        .toList();
  }
}
