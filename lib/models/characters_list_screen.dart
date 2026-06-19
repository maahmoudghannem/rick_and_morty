// ============================================================
// characters_list_screen.dart
// Screen 1 — the main grid of all Rick & Morty characters.
//
// Architecture:
// • StatefulWidget + setState (no external state management)

// • Manual pagination triggered by ScrollController
// • Pull-to-refresh via RefreshIndicator
// • Each card is its own private StatelessWidget (_CharacterCard)
// ============================================================

import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_services.dart';
import 'character_detail_screen.dart';

// ─────────────────────────────────────────────────────────────
// CharactersListScreen (the StatefulWidget shell)

// ─────────────────────────────────────────────────────────────

/// The root screen of the app. Fetches and displays every character
/// in a 2-column grid with infinite scroll pagination.
class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

// ─────────────────────────────────────────────────────────────
// _CharactersListScreenState (holds all mutable state)
// ─────────────────────────────────────────────────────────────
class _CharactersListScreenState extends State<CharactersListScreen> {
  // ── Dependencies ──────────────────────────────────────────
  /// Service that owns all API calls — created once, lives with the State
  final ApiService _apiService = ApiService();

  // ── Scroll ────────────────────────────────────────────────

  /// Attached to the GridView to listen for scroll position changes.
  /// Used to detect when the user nears the bottom (infinite scroll).
  final ScrollController _scrollController = ScrollController();

  // ── Data ──────────────────────────────────────────────────
  /// Accumulates characters from all pages fetched so far.
  /// New pages are appended here; the grid reads from this list.
  final List<Character> _characters = [];

  // ── Pagination ────────────────────────────────────────────
  /// The next page number to request. Starts at 1,
  int _currentPage = 1;

  /// Total number of pages the API says exist. Used to know when to stop.
  int _totalPages = 1;

  // ── UI State Flags ────────────────────────────────────────
  /// True while an API call is in-flight. Prevents duplicate concurrent calls.
  bool _isLoading = false;

  /// Becomes true once the very first page has successfully loaded.
  /// Controls which body widget is shown (spinner vs grid).
  bool _hasInitialData = false;

  /// Holds an error message string if the latest API call failed.
  /// Null means no error. Only shown to the user when there is NO data yet.
  String? _errorMessage;

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Kick off the initial data load as soon as this widget enters the tree
    _fetchCharacters();

    // Register the scroll listener for infinite pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Remove the listener first to avoid callbacks on a disposed widget
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll Logic ──────────────────────────────────────────

  /// Called on every scroll event. If the user is within the last 15% of
  /// the scrollable area AND another page exists, fetch it automatically.
  void _onScroll() {
    // The pixel position at which we want to start loading the next page
    final double triggerPoint =
        _scrollController.position.maxScrollExtent * 0.85;

    final bool nearBottom = _scrollController.position.pixels >= triggerPoint;
    final bool hasMorePages = _currentPage <= _totalPages;

    if (nearBottom && !_isLoading && hasMorePages) {
      _fetchCharacters();
    }
  }

  // ── Data Fetching ─────────────────────────────────────────

  /// Fetches [_currentPage] from the API and appends the results to
  /// [_characters]. Manages [_isLoading] and [_errorMessage] state.
  Future<void> _fetchCharacters() async {
    // Guard: never fire two concurrent requests
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any stale error before retrying
    });

    try {
      // Await the paginated API response
      final CharacterApiResponse response = await _apiService.fetchCharacters(
        page: _currentPage,
      );

      setState(() {
        // Remember how many pages total exist (for infinite scroll guard)
        _totalPages = response.info.pages;

        // Append this page's characters to the growing master list
        _characters.addAll(response.results);

        // Advance the page cursor AFTER a successful fetch
        _currentPage++;

        _hasInitialData = true;
        _isLoading = false;
      });
    } catch (e) {
      // Store the error so the UI can display it, but don't crash
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Resets all state back to "empty" and re-fetches from page 1.
  /// Triggered by pull-to-refresh and the retry button on the error screen.
  Future<void> _refresh() async {
    setState(() {
      _characters.clear();
      _currentPage = 1;
      _totalPages = 1;
      _hasInitialData = false;
      _errorMessage = null;
    });
    await _fetchCharacters();
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14), // Deep space black-blue
      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A14),
        elevation: 0,
        centerTitle: true,
        // Branded two-tone title
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Rick ',
                style: TextStyle(
                  color: Color(0xFF00C8E8), // Portal cyan
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              TextSpan(
                text: '& ',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: 'Morty',

                style: TextStyle(
                  color: Color(0xFF9ADE07), // Portal green
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        // A slim subtitle row beneath the title showing character count
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _hasInitialData
                    ? '${_characters.length} characters loaded'
                    : 'Scanning the multiverse…',
                key: ValueKey<bool>(_hasInitialData),
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      // ── Body ────────────────────────────────────────────────
      body: _buildBody(),
    );
  }

  /// Selects the correct body widget based on current state:
  /// - Full-screen spinner on very first load
  /// - Full-screen error if initial load failed
  /// - Character grid once data is available
  Widget _buildBody() {
    // Case 1: First load in progress — show a centred spinner
    if (!_hasInitialData && _isLoading) {
      return _buildInitialLoadingView();
    }

    // Case 2: First load failed — show the error / retry screen
    if (!_hasInitialData && _errorMessage != null) {
      return _buildErrorView();
    }

    // Case 3: We have data — show the scrollable grid (loading more at bottom)

    return _buildCharacterGrid();
  }

  // ── Sub-Widgets ───────────────────────────────────────────

  /// Full-screen centred loading spinner shown only on the very first load.
  Widget _buildInitialLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinning portal indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Color(0xFF00C8E8),

              strokeWidth: 3,
              backgroundColor: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Opening the portal…',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when the initial API call fails (no characters to display yet).

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                  color: const Color(0xFF00C8E8).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFF00C8E8),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Portal gun misfired.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Show the actual error message for debugging context
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 28),
            // Retry button — triggers a full reset and re-fetch
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8E8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The main 2-column character grid. Wraps [GridView.builder] in a
  /// [RefreshIndicator] so pull-to-refresh works out of the box.
  Widget _buildCharacterGrid() {
    return RefreshIndicator(
      onRefresh: _refresh,

      color: const Color(0xFF00C8E8),
      backgroundColor: const Color(0xFF1A1A2E),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        // 2-column layout; cards are slightly taller than wide
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        // When loading more pages, add 1 extra slot for the bottom spinner
        itemCount: _characters.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // The last item slot is reserved for the "loading more" indicator
          if (index >= _characters.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF00C8E8),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          // Render the character card for this grid position
          return _CharacterCard(character: _characters[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _CharacterCard (private, stateless card widget)
// ─────────────────────────────────────────────────────────────

/// A single character card shown inside the grid.
/// Extracted into its own widget so [GridView] can cache and recycle it
/// independently — improves scroll performance on long lists.
class _CharacterCard extends StatelessWidget {
  /// All character data needed to render this card

  final Character character;

  const _CharacterCard({required this.character});

  // ── Helpers ───────────────────────────────────────────────

  /// Maps a status string to a semantic colour for the indicator dot.
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF4ADE80); // Vivid green
      case 'dead':
        return const Color(0xFFEF4444); // Bold red
      default:
        return const Color(0xFF94A3B8); // Muted slate for "unknown"
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ── Tap → navigate to detail screen ───────────────────────────────
      // The full [character] object is passed through the constructor;
      // no ID lookup or extra API call is needed on the detail screen.
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          // Smooth fade+scale transition between screens
          pageBuilder: (context, animation, __) =>
              CharacterDetailScreen(character: character),
          transitionsBuilder: (context, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      // ── Card Container ──────────────────────────────────────────────
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF141428),
          // Multi-layer shadow for a deep, floating look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF00C8E8).withOpacity(0.04),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        // ClipRRect ensures the image and gradient
        // respect the border radius
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Character Portrait ─────────────────────────────────
              // Image.network is used as required (no cached_network_image)
              Image.network(
                character.image,
                fit: BoxFit.cover, // Cover the full card area
                // Progressive loading placeholder
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child; // Loaded — show image
                  return Container(
                    color: const Color(0xFF1A1A2E),

                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C8E8),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                // Fallback if the CDN URL is broken
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                    size: 40,
                  ),
                ),
              ),

              // ── Bottom Gradient Overlay + Name Section ─────────────
              // This is the "shadow effect" requirement: a gradient that
              // fades from transparent (top) to near-black (bottom),
              // with the name and status text sitting on top of it.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xF0000000), // Solid black at the very bottom
                        Color(0x88000000), // Semi-transparent midpoint
                        Colors.transparent, // Fades into the image above
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Character name — bold, two-line max
                      Text(
                        character.name,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status row: coloured dot + "Alive · Human" label
                      Row(
                        children: [
                          // Glowing status indicator dot
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusColor(character.status),
                              boxShadow: [
                                BoxShadow(
                                  color: _statusColor(character.status),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${character.status} · ${character.species}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,

                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Subtle top-left ID badge ───────────────────────────
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${character.id}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
