// ============================================================
// api_service.dart
// A dedicated service class that owns ALL network communication.
// Uses the Dio HTTP client to fetch character data from the
// Rick & Morty REST API.  Nothing in the UI layer touches Dio
// directly — they call methods on this service instead.
// ============================================================

import 'package:dio/dio.dart';
import 'package:discovery/screens/character_model.dart';


/// Handles all HTTP communication with the Rick & Morty public API.
/// Construct once and reuse — [Dio] manages its own connection pool.
class ApiService {
  /// The root URL that all endpoint paths are appended to
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  /// The configured [Dio] instance. Created in the constructor with
  /// sensible timeout defaults so the app never hangs indefinitely.
  final Dio _dio;

  /// Constructor: sets up the [Dio] client with base options.
  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          // Maximum time to wait while establishing a TCP connection
          connectTimeout: const Duration(seconds: 10),
          // Maximum time to wait for the full response body to arrive
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// Fetches one page of characters from the `/character` endpoint.
  ///
  /// [page] starts at 1. The API returns up to 20 characters per page
  /// and a total of ~42 pages (826 characters as of the last API update).
  ///
  /// Returns a fully parsed [CharacterApiResponse] on success.
  /// Throws an [Exception] with a human-readable message on failure.
  Future<CharacterApiResponse> fetchCharacters({int page = 1}) async {
    try {
      // GET https://rickandmortyapi.com/api/character?page=1
      final Response response = await _dio.get(
        '/character',
        queryParameters: {'page': page}, // Appended as ?page=N
      );

      // response.data is already decoded from JSON by Dio (it's a Map).
      // Parse it into our typed model.
      return CharacterApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Wrap the Dio-specific error in a plain [Exception] so the UI layer
      // doesn't need to import or know about Dio at all.
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors (e.g., type cast failures)
      throw Exception('Unexpected error: $e');
    }
  }
}
