import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ocr_services.dart';
import '../utils/permissions.dart';
import '../widgets/scanner_button.dart';
import 'save_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _image;
  bool _isProcessing = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasCameraPermission = await PermissionUtils.hasCameraPermission();
    final hasStoragePermission = await PermissionUtils.hasStoragePermission();

    if (!hasCameraPermission || !hasStoragePermission) {
      final permissions = await PermissionUtils.requestAllPermissions();
      if (permissions[Permission.camera]!.isDenied) {
        setState(() {
          _isError = true;
          _errorMessage = 'Camera permission is required for scanning documents';
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (picked != null) {
        File imageFile = File(picked.path);
        setState(() {
          _image = imageFile;
          _isError = false;
        });
        
        _performOCR(imageFile);
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _performOCR(File imageFile) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final extractedText = await OCRService.extractTextFromImage(imageFile);
      final suggestedTitle = OCRService.suggestTitle(extractedText);
      final suggestedTags = OCRService.suggestTags(extractedText);
      final keyInfo = OCRService.analyzeReceiptText(extractedText);
      
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      // Navigate to save screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaveScreen(
            imageFile: imageFile,
            extractedText: extractedText,
            suggestedTitle: suggestedTitle,
            suggestedTags: suggestedTags,
            keyInfo: keyInfo,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isError = true;
        _errorMessage = 'Error processing image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 32),
                _buildCaptureOptions(),
                if (_isError) _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: _image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),
        ),
        if (_isProcessing)
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Extracting text...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureOptions() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Capture Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScannerButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                  color: Theme.of(context).colorScheme.primary,
                ),
                ScannerButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                ScannerButton(
                  icon: Icons.file_copy,
                  label: 'Document',
                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Scan any document, receipt, ID, or note\nOCR will automatically extract the text',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
