import 'package:dio/dio.dart';

/// HTTP client for the small number of live PokéAPI lookups.
///
/// LibreDex keeps its core reference data locally. This client is only used
/// when an evolution screen asks PokéAPI for the current chain, and the
/// repository supplies a bundled fallback when that request is unavailable.
class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  static Future<Response<dynamic>> get(String endpoint) => _dio.get(endpoint);
}
