// ============================================================
// character_model.dart
// Defines all data classes that mirror the Rick & Morty API's
// JSON structure. Each class has a factory constructor that
// parses a raw JSON map into a typed Dart object.
// ============================================================

/// Represents the birthplace / dimensional origin of a character.
/// Example: { "name": "Earth (C-137)", "url": "https://..." }
class CharacterOrigin {
  /// The human-readable name of the origin location
  final String name;

  /// The API URL to fetch more details about this origin planet/dimension
  final String url;

  CharacterOrigin({required this.name, required this.url});

  /// Parses a JSON map from the API into a [CharacterOrigin] object.
  /// Uses the null-coalescing operator (??) to provide safe fallback values.
  factory CharacterOrigin.fromJson(Map<String, dynamic> json) {
    return CharacterOrigin(
      name: json['name'] as String? ?? 'Unknown',
      url: json['url'] as String? ?? '',
    );
  }
}

/// Represents the character's last known location in the multiverse.
/// Structurally identical to [CharacterOrigin] but semantically different.
class CharacterLocation {
  /// The human-readable name of the current location
  final String name;

  /// The API URL to fetch more details about this location
  final String url;

  CharacterLocation({required this.name, required this.url});

  /// Parses a JSON map from the API into a [CharacterLocation] object.
  factory CharacterLocation.fromJson(Map<String, dynamic> json) {
    return CharacterLocation(
      name: json['name'] as String? ?? 'Unknown',
      url: json['url'] as String? ?? '',
    );
  }
}

/// The main data model representing one Rick & Morty character.
/// Maps 1-to-1 with the JSON objects inside the API's "results" array.
class Character {
  /// Unique numeric identifier assigned by the API (e.g., 1 = Rick Sanchez)
  final int id;

  /// The character's full display name
  final String name;

  /// Life status: one of "Alive", "Dead", or "unknown"
  final String status;

  /// Biological species (e.g., "Human", "Alien", "Robot")
  final String species;

  /// More specific sub-type within the species. Empty string if not applicable.
  final String type;

  /// Gender identity: "Female", "Male", "Genderless", or "unknown"
  final String gender;

  /// Where this character originally came from (planet, dimension, etc.)
  final CharacterOrigin origin;

  /// The most recently known location for this character
  final CharacterLocation location;

  /// Direct CDN URL to the character's portrait image (300x300 px)
  final String image;

  /// A list of API URLs — one per episode this character appeared in.
  /// The count of this list tells us how many episodes they were in.
  final List<String> episode;

  /// The canonical API URL for this character's own endpoint
  final String url;

  /// ISO 8601 timestamp of when this character entry was created in the DB
  final String created;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
    required this.url,
    required this.created,
  });

  /// Parses a single character JSON object from the API's "results" array.
  /// Handles nested objects (origin, location) and the episode URL list.
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'Unknown',
      species: json['species'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Unknown',
      // Recursively parse the nested "origin" JSON object
      origin: CharacterOrigin.fromJson(
        json['origin'] as Map<String, dynamic>? ?? {},
      ),
      // Recursively parse the nested "location" JSON object
      location: CharacterLocation.fromJson(
        json['location'] as Map<String, dynamic>? ?? {},
      ),
      image: json['image'] as String? ?? '',
      // Cast the dynamic list to List<String> safely
      episode: List<String>.from(json['episode'] as List? ?? []),
      url: json['url'] as String? ?? '',
      created: json['created'] as String? ?? '',
    );
  }
}

/// Top-level wrapper for the paginated character list endpoint.
/// The API returns: { "info": {...}, "results": [...] }
class CharacterApiResponse {
  /// Pagination metadata: total count, total pages, next/prev page URLs
  final ApiInfo info;

  /// The 20 characters (max) belonging to the current page
  final List<Character> results;

  CharacterApiResponse({required this.info, required this.results});

  /// Parses the outermost API response JSON into this wrapper object.
  factory CharacterApiResponse.fromJson(Map<String, dynamic> json) {
    return CharacterApiResponse(
      info: ApiInfo.fromJson(json['info'] as Map<String, dynamic>? ?? {}),
      // Map each raw JSON object in "results" to a typed [Character]
      results: (json['results'] as List? ?? [])
          .map((item) => Character.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Holds the pagination metadata returned alongside every character list page.
class ApiInfo {
  /// Grand total number of characters across ALL pages
  final int count;

  /// Total number of pages available (each page has up to 20 characters)
  final int pages;

  /// Full URL of the next page, or null if we're on the last page
  final String? next;

  /// Full URL of the previous page, or null if we're on the first page
  final String? prev;

  ApiInfo({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  /// Parses the "info" section of the API response JSON
  factory ApiInfo.fromJson(Map<String, dynamic> json) {
    return ApiInfo(
      count: json['count'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}