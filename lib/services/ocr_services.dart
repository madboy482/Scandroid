import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  // Extract text from an image using Google ML Kit
  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error extracting text from image: $e');
      return '';
    }
  }
  
  // Get key information from extracted text (e.g., dates, amounts, etc.)
  static Map<String, String> analyzeReceiptText(String text) {
    final Map<String, String> result = {};
    
    // Extract date (simple pattern matching for common formats)
    final dateRegex = RegExp(r'\b\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}\b');
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      result['date'] = dateMatch.group(0) ?? '';
    }
    
    // Extract amount (looking for currency symbols or "total")
    final amountRegex = RegExp(r'(?:total|amount|sum|[\$€£¥])[\s:]*[\$€£¥]?\s*\d+[.,]\d{2}', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      result['amount'] = amountMatch.group(0) ?? '';
    }
    
    // Extract merchant/business name (usually at the top of receipts)
    final lines = text.split('\n');
    if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
      result['merchant'] = lines[0].trim();
    }
    
    return result;
  }
  
  // Suggest tags based on extracted text
  static List<String> suggestTags(String text) {
    final List<String> suggestedTags = [];
    final String lowerText = text.toLowerCase();
    
    // Common categories to check for
    final Map<String, List<String>> categories = {
      'food': ['restaurant', 'meal', 'dinner', 'lunch', 'breakfast', 'cafe', 'coffee'],
      'travel': ['airline', 'flight', 'hotel', 'booking', 'train', 'taxi', 'uber'],
      'shopping': ['store', 'mall', 'purchase', 'buy', 'item', 'product'],
      'utilities': ['electric', 'water', 'gas', 'bill', 'utility', 'internet', 'phone'],
      'entertainment': ['movie', 'cinema', 'theater', 'concert', 'show', 'ticket'],
    };
    
    // Check for keywords in each category
    categories.forEach((category, keywords) {
      for (final keyword in keywords) {
        if (lowerText.contains(keyword)) {
          suggestedTags.add(category);
          break;
        }
      }
    });
    
    return suggestedTags;
  }
  
  // Suggest a title based on extracted text
  static String suggestTitle(String text) {
    final lines = text.split('\n');
    String title = '';
    
    // Try to use first non-empty line as title
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        title = line.trim();
        // Limit title length
        if (title.length > 30) {
          title = '${title.substring(0, 27)}...';
        }
        break;
      }
    }
    
    // If no suitable title found, use current date
    if (title.isEmpty) {
      final now = DateTime.now();
      title = 'Scan ${now.day}/${now.month}/${now.year}';
    }
    
    return title;
  }
}