import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';
import '../providers/capture_provider.dart';

class LocalApiService {
  final ProviderContainer container;
  HttpServer? _server;

  LocalApiService(this.container);

  Future<void> start() async {
    // Only run the local API server on desktop platforms where the user will be using the Chrome extension
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4758);
      debugPrint('Local API Server running on localhost:4758');

      await for (var request in _server!) {
        _handleRequest(request);
      }
    } catch (e) {
      debugPrint('Failed to start local API server: $e');
    }
  }

  void stop() {
    _server?.close(force: true);
    _server = null;
  }

  void _handleRequest(HttpRequest request) async {
    // Handle CORS preflight
    if (request.method == 'OPTIONS') {
      _setCorsHeaders(request.response);
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    // Set CORS headers for all responses
    _setCorsHeaders(request.response);

    if (request.uri.path == '/capture' && request.method == 'POST') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;

        final url = data['url'] as String?;
        final title = data['title'] as String?;
        final text = data['text'] as String?; // Optional highlighted text

        if (url == null) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('{"error": "Missing URL"}');
          await request.response.close();
          return;
        }

        // Construct capture content
        String captureContent = url;
        if (text != null && text.isNotEmpty) {
          captureContent = '"$text"\n\nSource: $url';
        }

        final input = CaptureInput(
          type: 'link',
          content: captureContent,
          title: title ?? 'Saved from Chrome Extension',
          metadata: {'source': 'browser_extension', 'url': url},
        );

        await container.read(captureListNotifierProvider.notifier).addCapture(input);

        request.response.statusCode = HttpStatus.ok;
        request.response.write('{"success": true}');
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write('{"error": "$e"}');
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('{"error": "Not found"}');
    }

    await request.response.close();
  }

  void _setCorsHeaders(HttpResponse response) {
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type');
  }
}
