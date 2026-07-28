import 'package:dio/dio.dart';

/// Pre-configured Dio client for communicating with PokeAPI (https://pokeapi.co/).
/// Handles unified connection timeouts, basic interceptors and centralized exception handling.
class ApiClient {
  ApiClient._();

  static const String _baseUrl = 'https://pokeapi.co/api/v2/';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Additional custom configurations (headers, caching, etc.) go here
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final errorMessage = _handleError(error);
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: errorMessage,
            ),
          );
        },
      ),
    );

  /// Performs a standardized, safe asynchronous GET request.
  /// 
  /// Example:
  /// ```dart
  /// final response = await ApiClient.get('pokemon/pikachu');
  /// ```
  static Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected network error occurred: $e');
    }
  }

  /// Translates standard raw exceptions into user-friendly description strings.
  static String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout with server. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send request timeout. Please check your connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. The PokeAPI might be overloaded.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request. Invalid endpoint or parameters.';
          case 404:
            return 'Requested Pokémon or resource was not found.';
          case 500:
            return 'PokeAPI internal server error. Please try again later.';
          default:
            return 'PokeAPI returned status code: $statusCode';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection detected. Please verify your connection.';
      default:
        return 'An unexpected network error occurred. Please check your connection.';
    }
  }
}
