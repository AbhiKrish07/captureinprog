import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

// Same vector math logic for CLI
import 'dart:math';

class VectorMath {
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    if (a.isEmpty) return 0.0;
    double dotProduct = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
  static List<double> generateMockEmbedding(String text) {
    final random = Random(text.hashCode);
    return List.generate(1536, (_) => random.nextDouble() * 2 - 1.0);
  }
}

Future<void> main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  String getDbPath() {
    if (Platform.isWindows) {
      return join(Platform.environment['USERPROFILE']!, 'Documents', 'capture_app.db');
    } else {
      return join(Platform.environment['HOME']!, 'Documents', 'capture_app.db');
    }
  }

  final db = await databaseFactory.openDatabase(getDbPath());

  // Listen to stdin
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) async {
    try {
      final request = jsonDecode(line);
      if (request['jsonrpc'] != '2.0') return;
      
      final method = request['method'];
      final params = request['params'] ?? {};
      final id = request['id'];

      if (method == 'initialize') {
        _sendResponse(id, {
          'protocolVersion': '2024-11-05',
          'capabilities': {'tools': {}},
          'serverInfo': {'name': 'capture-mcp', 'version': '1.0.0'}
        });
      } else if (method == 'tools/list') {
        _sendResponse(id, {
          'tools': [
            {
              'name': 'search_captures',
              'description': 'Search saved context conceptually.',
              'inputSchema': {
                'type': 'object',
                'properties': {'query': {'type': 'string'}},
                'required': ['query']
              }
            },
            {
              'name': 'get_recent_context',
              'description': 'Get the most recently saved items.',
              'inputSchema': {
                'type': 'object',
                'properties': {'limit': {'type': 'number'}},
                'required': []
              }
            },
            {
              'name': 'add_new_capture',
              'description': 'Add new context to the database.',
              'inputSchema': {
                'type': 'object',
                'properties': {'content': {'type': 'string'}, 'type': {'type': 'string'}},
                'required': ['content', 'type']
              }
            }
          ]
        });
      } else if (method == 'tools/call') {
        final toolName = params['name'];
        final toolArgs = params['arguments'] ?? {};

        if (toolName == 'search_captures') {
          final query = toolArgs['query'] as String;
          final queryEmbedding = VectorMath.generateMockEmbedding(query);
          final maps = await db.query('captures');
          
          var results = maps.map((map) {
            final embeddingStr = map['embedding'] as String?;
            final embedding = embeddingStr != null ? List<double>.from(jsonDecode(embeddingStr)) : null;
            final score = embedding != null ? VectorMath.cosineSimilarity(queryEmbedding, embedding) : 0.0;
            return {
              'id': map['id'],
              'content': map['content'],
              'type': map['type'],
              'relevance': score,
            };
          }).toList();
          
          results.sort((a, b) => (b['relevance'] as double).compareTo(a['relevance'] as double));
          
          _sendResponse(id, {
            'content': [
              {'type': 'text', 'text': jsonEncode(results.take(5).toList())}
            ]
          });
        } else if (toolName == 'get_recent_context') {
          final limit = toolArgs['limit'] ?? 5;
          final maps = await db.query('captures', orderBy: 'createdAt DESC', limit: limit);
          _sendResponse(id, {
            'content': [
              {'type': 'text', 'text': jsonEncode(maps.map((m) => {'content': m['content'], 'type': m['type']}).toList())}
            ]
          });
        } else if (toolName == 'add_new_capture') {
          final content = toolArgs['content'] as String;
          final type = toolArgs['type'] as String;
          final now = DateTime.now().millisecondsSinceEpoch;
          
          await db.insert('captures', {
            'id': const Uuid().v4(),
            'userId': 'cli_user',
            'type': type,
            'content': content,
            'embedding': jsonEncode(VectorMath.generateMockEmbedding(content)),
            'createdAt': now,
            'updatedAt': now,
            'relatedSpaceIds': '[]',
          });
          
          _sendResponse(id, {
            'content': [
              {'type': 'text', 'text': 'Capture added successfully.'}
            ]
          });
        } else {
          _sendError(id, -32601, 'Tool not found');
        }
      } else {
         _sendError(id, -32601, 'Method not found');
      }
    } catch (e) {
      // Ignore parse errors or send basic error
    }
  });
}

void _sendResponse(dynamic id, Map<String, dynamic> result) {
  final response = {
    'jsonrpc': '2.0',
    'id': id,
    'result': result,
  };
  stdout.writeln(jsonEncode(response));
}

void _sendError(dynamic id, int code, String message) {
  final response = {
    'jsonrpc': '2.0',
    'id': id,
    'error': {'code': code, 'message': message},
  };
  stdout.writeln(jsonEncode(response));
}
