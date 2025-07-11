import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String baseUrl = "https://arloop-server.onrender.com/";
  static const int timeoutDuration = 30; // seconds
  
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // HTTP client instance
  final http.Client _client = http.Client();
  
  // Authentication token
  String? _authToken;
  
  // Default headers
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = {..._defaultHeaders, ...?headers};

      _logRequest('GET', uri.toString(), requestHeaders);

      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      _logRequest('POST', uri.toString(), requestHeaders, jsonBody);

      final response = await _client
          .post(uri, headers: requestHeaders, body: jsonBody)
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      _logRequest('PUT', uri.toString(), requestHeaders, jsonBody);

      final response = await _client
          .put(uri, headers: requestHeaders, body: jsonBody)
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      _logRequest('PATCH', uri.toString(), requestHeaders, jsonBody);

      final response = await _client
          .patch(uri, headers: requestHeaders, body: jsonBody)
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = {..._defaultHeaders, ...?headers};

      _logRequest('DELETE', uri.toString(), requestHeaders);

      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Multipart request (for file uploads)
  Future<ApiResponse<T>> multipart<T>(
    String endpoint, {
    required String method,
    Map<String, String>? headers,
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      // Add headers
      final requestHeaders = {..._defaultHeaders, ...?headers};
      requestHeaders.remove('Content-Type'); // Let multipart set its own content type
      request.headers.addAll(requestHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      _logRequest(method.toUpperCase(), uri.toString(), request.headers);

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: timeoutDuration));

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? headers,
    Map<String, String>? additionalFields,
    T Function(dynamic)? fromJson,
  }) async {
    return multipart<T>(
      endpoint,
      method: 'POST',
      headers: headers,
      fields: additionalFields,
      files: {fieldName: file},
      fromJson: fromJson,
    );
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final url = endpoint.startsWith('http') ? endpoint : baseUrl + endpoint;
    final uri = Uri.parse(url);
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return Uri.parse('$url?$queryString');
    }
    
    return uri;
  }

  /// Handle response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    _logResponse(response);

    final statusCode = response.statusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    try {
      final dynamic responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;

      if (isSuccess) {
        T? data;
        if (fromJson != null && responseData != null) {
          data = fromJson(responseData);
        } else {
          data = responseData as T?;
        }

        return ApiResponse<T>(
          data: data,
          statusCode: statusCode,
          message: _getSuccessMessage(statusCode),
          isSuccess: true,
        );
      } else {
        final errorMessage = _extractErrorMessage(responseData);
        return ApiResponse<T>(
          data: null,
          statusCode: statusCode,
          message: errorMessage,
          isSuccess: false,
          error: responseData,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        statusCode: statusCode,
        message: 'Failed to parse response: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    String errorMessage;
    int statusCode = 0;

    if (error is SocketException) {
      errorMessage = 'No internet connection';
      statusCode = 0;
    } else if (error is HttpException) {
      errorMessage = 'HTTP error: ${error.message}';
      statusCode = 0;
    } else if (error is FormatException) {
      errorMessage = 'Invalid response format';
      statusCode = 0;
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timeout';
      statusCode = 408;
    } else {
      errorMessage = 'Unknown error: $error';
      statusCode = 0;
    }

    _logError(errorMessage);

    return ApiResponse<T>(
      data: null,
      statusCode: statusCode,
      message: errorMessage,
      isSuccess: false,
      error: error,
    );
  }

  /// Extract error message from response
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'Unknown error occurred';
    
    if (responseData is Map<String, dynamic>) {
      // Try common error message keys
      final errorKeys = ['message', 'error', 'msg', 'detail', 'description'];
      for (final key in errorKeys) {
        if (responseData.containsKey(key)) {
          final value = responseData[key];
          if (value is String) return value;
          if (value is Map || value is List) return value.toString();
        }
      }
    }
    
    return responseData.toString();
  }

  /// Get success message based on status code
  String _getSuccessMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'Request successful';
      case 201:
        return 'Resource created successfully';
      case 202:
        return 'Request accepted';
      case 204:
        return 'Request successful (no content)';
      default:
        return 'Request completed';
    }
  }

  /// Log request
  void _logRequest(String method, String url, Map<String, String> headers, [String? body]) {
    if (kDebugMode) {
      print('🚀 API Request: $method $url');
      print('📋 Headers: $headers');
      if (body != null) {
        print('📦 Body: $body');
      }
    }
  }

  /// Log response
  void _logResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 API Response: ${response.statusCode}');
      print('📄 Body: ${response.body}');
    }
  }

  /// Log error
  void _logError(String error) {
    if (kDebugMode) {
      print('❌ API Error: $error');
    }
  }

  /// Close the client
  void close() {
    _client.close();
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String message;
  final bool isSuccess;
  final dynamic error;

  ApiResponse({
    this.data,
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.error,
  });

  @override
  String toString() {
    return 'ApiResponse{data: $data, statusCode: $statusCode, message: $message, isSuccess: $isSuccess}';
  }
}

