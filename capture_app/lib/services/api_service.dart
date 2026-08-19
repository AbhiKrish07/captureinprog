import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';

import '../providers/auth_provider.dart';

class ApiService {
  final Dio _dio;
  
  ApiService({String? baseUrl, String? authToken}) 
    : _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'http://localhost:8000',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[API] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('[API ERROR] ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // CAPTURE ENDPOINTS
  
  /// Create a new capture
  Future<Capture> createCapture(CaptureInput input) async {
    try {
      final response = await _dio.post(
        '/captures',
        data: input.toJson(),
      );
      return Capture.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload a capture file
  Future<Capture> uploadCaptureFile({
    required File file,
    required String type,
    String? title,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final Map<String, dynamic> data = {
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': type,
      };
      if (title != null) {
        data['title'] = title;
      }
      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        '/captures/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Capture.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search captures with semantic query
  Future<List<Capture>> searchCaptures({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/captures/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );
      return (response.data['results'] as List)
          .map((c) => Capture.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get a single capture
  Future<Capture> getCapture(String id) async {
    try {
      final response = await _dio.get('/captures/$id');
      return Capture.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// List all captures (paginated)
  Future<(List<Capture>, int)> listCaptures({
    int limit = 20,
    int offset = 0,
    String? module,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};
      if (module != null) {
        queryParams['module'] = module;
      }
      
      final response = await _dio.get(
        '/captures',
        queryParameters: queryParams,
      );
      final captures = (response.data['items'] as List)
          .map((c) => Capture.fromJson(c))
          .toList();
      final total = response.data['total'] as int;
      return (captures, total);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update a capture
  Future<Capture> updateCapture(String id, {
    String? title,
    String? content,
    String? preview,
    Map<String, dynamic>? metadata,
    List<String>? spaceIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (preview != null) data['preview'] = preview;
      if (metadata != null) data['metadata'] = metadata;
      if (spaceIds != null) data['space_ids'] = spaceIds;

      final response = await _dio.patch(
        '/captures/$id',
        data: data,
      );
      return Capture.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a capture
  Future<void> deleteCapture(String id) async {
    try {
      await _dio.delete('/captures/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // SPACE ENDPOINTS
  Future<void> updateSpace(String id, {String? name, String? description, Map<String, dynamic>? canvasState}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (canvasState != null) data['canvas_state'] = canvasState;
      await _dio.patch('/spaces/$id', data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }


  // ERROR HANDLING
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? e.message;
      return 'Error: $message';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond.';
    }
    return 'Network error: ${e.message}';
  }
}



// Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authToken = client.auth.currentSession?.accessToken;
  
  // Using the host PC's local IP address so the physical phone can reach the FastAPI backend
  String baseUrl = 'http://10.165.56.21:8000';
  
  return ApiService(
    baseUrl: baseUrl, 
    authToken: authToken,
  );
});
