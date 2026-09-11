import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Pulls plain text out of a picked file so it can be attached as context
/// for the AI chat. Supports PDFs (via Syncfusion's PDF text extractor,
/// no UI/license prompt needed for this text-only use) and plain .txt
/// files. Other file types raise a clear error instead of failing silently.
class FileTextExtractor {
  /// Caps how much text we forward to the AI in one go — long documents
  /// get truncated so a single request doesn't blow past the model's
  /// context window or the free-tier token budget.
  static const int maxChars = 12000;

  static Future<String> extractText(String filePath, String fileName) async {
    final extension = fileName.toLowerCase().split('.').last;

    if (extension == 'pdf') {
      return _extractFromPdf(filePath);
    }
    if (extension == 'txt' || extension == 'md') {
      return _extractFromPlainText(filePath);
    }

    throw UnsupportedError(
      'Only PDF and plain text (.txt/.md) files are supported for AI context right now.',
    );
  }

  static Future<String> _extractFromPdf(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      return _truncate(text);
    } finally {
      document.dispose();
    }
  }

  static Future<String> _extractFromPlainText(String filePath) async {
    final text = await File(filePath).readAsString();
    return _truncate(text);
  }

  static String _truncate(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars)}\n\n[...truncated for length]';
  }
}