import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/document_provider.dart';
import '../services/biometric_service.dart';
import '../widgets/document_card.dart';
import 'document_view_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _authenticate();

    // Initialize documents
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isAuthenticated) {
        Provider.of<DocumentProvider>(context, listen: false).initDocuments();
      }
    });
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    
    final biometricService = Provider.of<BiometricService>(context, listen: false);
    final canCheckBiometrics = await biometricService.isBiometricAvailable();
    
    if (canCheckBiometrics) {
      final authenticated = await biometricService.authenticate();
      setState(() => _isAuthenticated = authenticated);
    } else {
      // If biometrics not available, allow access
      setState(() => _isAuthenticated = true);
    }
    
    setState(() => _isAuthenticating = false);
    
    // Initialize documents after authentication
    if (_isAuthenticated) {
      Provider.of<DocumentProvider>(context, listen: false).initDocuments();
    }
  }

  void _onSearchChanged(String query) {
    Provider.of<DocumentProvider>(context, listen: false).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<DocumentProvider>(context, listen: false).setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Authenticating...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Authentication required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Scandroid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DocumentSearchDelegate(context),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFolderSelector(),
          Expanded(
            child: _buildDocumentGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildFolderSelector() {
    return Consumer<DocumentProvider>(
      builder: (ctx, docProvider, _) {
        return Container(
          height: 50,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docProvider.folders.length,
            itemBuilder: (context, index) {
              final folder = docProvider.folders[index];
              final isSelected = folder == docProvider.currentFolder;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(folder),
                  selected: isSelected,
                  onSelected: (_) {
                    docProvider.setCurrentFolder(folder);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDocumentGrid() {
    return Consumer<DocumentProvider>(
      builder: (ctx, docProvider, _) {
        if (docProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = docProvider.documents;
        
        if (documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.document_scanner,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No documents found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan a Document'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScannerScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return DocumentCard(document: documents[index]);
            },
          ),
        );
      },
    );
  }
}

class DocumentSearchDelegate extends SearchDelegate<String> {
  final BuildContext context;

  DocumentSearchDelegate(this.context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Type something to search'),
      );
    }
    
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    docProvider.setSearchQuery(query);
    
    return Consumer<DocumentProvider>(
      builder: (ctx, docProvider, _) {
        final results = docProvider.searchByText(query);
        
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final document = results[index];
            return ListTile(
              title: Text(
                document.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                document.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              leading: const Icon(Icons.description),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentViewScreen(document: document),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Type something to search'),
      );
    }
    
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final results = docProvider.searchByText(query);
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final document = results[index];
        return ListTile(
          title: Text(document.title),
          subtitle: Text(
            document.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.description),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentViewScreen(document: document),
              ),
            );
          },
        );
      },
    );
  }
}
