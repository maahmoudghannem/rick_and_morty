// ============================================================
// character_detail_screen.dart
// Screen 2 — full detail view for one Rick & Morty character.
//
// Receives the pre-fetched [Character] object via its constructor
// (no additional API call needed). Uses a CustomScrollView with a
// SliverAppBar to create a collapsing hero-image header effect.
// ============================================================

import 'package:flutter/material.dart';
import '../models/character_model.dart';

/// Displays every field of a [Character] in a polished,
/// scrollable layout with a large collapsible image header.
class CharacterDetailScreen extends StatelessWidget {
  /// The character to display — passed in from the list screen.
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  // ── Helpers ───────────────────────────────────────────────

  /// Returns the semantic colour for a given status string.
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF4ADE80);
      case 'dead':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Returns an appropriate [IconData] for a given info label string.
  /// Used to make each info tile visually distinct.
  IconData _iconFor(String label) {
    switch (label) {
      case 'Species':
        return Icons.biotech_rounded;
      case 'Gender':
        return Icons.wc_rounded;
      case 'Type':
        return Icons.label_rounded;
      case 'Origin':
        return Icons.public_rounded;
      case 'Last Location':
        return Icons.location_on_rounded;
      case 'Episodes':
        return Icons.live_tv_rounded;
      case 'ID':
        return Icons.tag_rounded;
      case 'Added':
        return Icons.calendar_today_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// Parses an ISO 8601 date string like "2017-11-04T18:48:46.250Z"
  /// and returns a friendly format like "Nov 4, 2017".
  String _formatDate(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      const List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso; // Return raw string if parsing fails
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Collapsing Hero Image App Bar ──────────────────────
          _buildSliverAppBar(context),

          // ── 2. All Detail Content ─────────────────────────────────
          SliverToBoxAdapter(
            child: _buildDetailContent(context),
          ),
        ],
      ),
    );
  }

  // ── Section Builders ─────────────────────────────────────

  /// Builds the large collapsible app bar with the character image as
  /// a full-bleed background, plus an overlaid name/status badge.
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400, // Height when fully expanded
      pinned: true,        // Keep a slim bar visible when scrolled past
      stretch: true,       // Allow the image to stretch on over-scroll
      backgroundColor: const Color(0xFF0A0A14),
      // Custom back button in a semi-transparent pill
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white24,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full-bleed character portrait ──────────────────────
            Image.network(
              character.image,
              fit: BoxFit.cover,
              // Loading placeholder matching the background
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF141428),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00C8E8),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, err, _) => Container(
                color: const Color(0xFF141428),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white24,
                  size: 60,
                ),
              ),
            ),

            // ── Top vignette — darkens the top edge for the back button ──
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),

            // ── Bottom gradient — blends image into the info section ──
            const Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0A0A14), Colors.transparent],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: SizedBox(height: 120, width: double.infinity),
              ),
            ),

            // ── Name + Status overlaid at the bottom of the image ────
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Character name in bold white
                  Text(
                    character.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Status pill badge
                  IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _statusColor(character.status).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing status dot
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusColor(character.status),
                              boxShadow: [
                                BoxShadow(
                                  color: _statusColor(character.status),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            character.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the scrollable content area below the image.
  /// Organises character data into clearly labelled sections.
  Widget _buildDetailContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section: Character Stats ───────────────────────────────
          _buildSectionHeader('Character Stats'),
          const SizedBox(height: 12),
          // 2-column grid for the compact stat cards
          _buildStatsGrid(context),

          const SizedBox(height: 28),

          // ── Section: Locations ────────────────────────────────────
          _buildSectionHeader('Locations'),
          const SizedBox(height: 12),
          _buildInfoTile(
            icon: _iconFor('Origin'),
            label: 'Origin',
            value: character.origin.name,
            accentColor: const Color(0xFF00C8E8),
          ),
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: _iconFor('Last Location'),
            label: 'Last Known Location',
            value: character.location.name,
            accentColor: const Color(0xFF00C8E8),
          ),

          const SizedBox(height: 28),

          // ── Section: Screen Time ──────────────────────────────────
          _buildSectionHeader('Screen Time'),
          const SizedBox(height: 12),
          _buildEpisodeCard(),

          const SizedBox(height: 28),

          // ── Section: Database Info ────────────────────────────────
          _buildSectionHeader('Database Info'),
          const SizedBox(height: 12),
          _buildInfoTile(
            icon: _iconFor('ID'),
            label: 'Character ID',
            value: '#${character.id}',
            accentColor: const Color(0xFF9ADE07),
          ),
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: _iconFor('Added'),
            label: 'Added to Database',
            value: _formatDate(character.created),
            accentColor: const Color(0xFF9ADE07),
          ),
        ],
      ),
    );
  }

  // ── Reusable UI Components ────────────────────────────────

  /// A left-accent-bar section header, e.g. "CHARACTER STATS"
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        // Vertical cyan accent bar
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF00C8E8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  /// A 2-column [Wrap] of compact stat cards showing species, gender, and type.
  Widget _buildStatsGrid(BuildContext context) {
    // Build the list of stats to show; skip "Type" if it's empty
    final List<Map<String, String>> stats = [
      {'label': 'Species', 'value': character.species},
      {'label': 'Gender', 'value': character.gender},
      if (character.type.isNotEmpty)
        {'label': 'Type', 'value': character.type}
      else
        {'label': 'Type', 'value': 'N/A'},
    ];

    // Calculate card width: half the usable screen width minus gaps
    final double cardWidth =
        (MediaQuery.of(context).size.width - 40 - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map((stat) {
        return SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141428),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00C8E8).withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row with small icon
                Row(
                  children: [
                    Icon(
                      _iconFor(stat['label']!),
                      color: const Color(0xFF00C8E8),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stat['label']!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Value
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// A full-width horizontal info tile with an icon, label, and value.
  /// [accentColor] tints the icon background so sections feel distinct.
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141428),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon in a circular tinted container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Label + value column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small muted label above the value
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                // Main value text
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A special card for the episode count, highlighted with the green
  /// portal accent colour to make it stand out from the other info tiles.
  Widget _buildEpisodeCard() {
    final int count = character.episode.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Subtle gradient to differentiate from flat tiles
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9ADE07).withOpacity(0.08),
            const Color(0xFF141428),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF9ADE07).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Green-tinted icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF9ADE07).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.live_tv_rounded,
              color: Color(0xFF9ADE07),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Appearances',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              // Large, bold episode count in accent green
              Text(
                '$count ${count == 1 ? 'Episode' : 'Episodes'}',
                style: const TextStyle(
                  color: Color(0xFF9ADE07),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}