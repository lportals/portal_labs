import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A model representing a team's stats in a group stage standings table.
class _TeamStats {
  final String flag;
  final String name;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int gf;
  final int ga;
  final int pts;

  const _TeamStats({
    required this.flag,
    required this.name,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.gf,
    required this.ga,
    required this.pts,
  });

  int get gd => gf - ga;
}

/// Showcase for [ScrollableSubgroups] using World Cup group standings data.
class ScrollableSubgroupsShowcase extends StatefulWidget {
  const ScrollableSubgroupsShowcase({super.key});

  @override
  State<ScrollableSubgroupsShowcase> createState() =>
      _ScrollableSubgroupsShowcaseState();
}

class _ScrollableSubgroupsShowcaseState
    extends State<ScrollableSubgroupsShowcase> {
  /// Tracks which team names are currently being dismissed.
  final Set<String> _dismissing = {};

  /// The live data list — items are removed after their dismiss animation ends.
  late List<ScrollableSubgroupsData<_TeamStats>> _data;

  static const List<ScrollableSubgroupsData<_TeamStats>> _initialData = [
    ScrollableSubgroupsData(
      title: 'GROUP A',
      subGroups: [
        _TeamStats(flag: '🇳🇱', name: 'Netherlands',  played: 3, won: 2, drawn: 0, lost: 1, gf: 5, ga: 1,  pts: 6),
        _TeamStats(flag: '🇸🇳', name: 'Senegal',      played: 3, won: 2, drawn: 0, lost: 1, gf: 5, ga: 4,  pts: 6),
        _TeamStats(flag: '🇪🇨', name: 'Ecuador',      played: 3, won: 1, drawn: 1, lost: 1, gf: 4, ga: 3,  pts: 4),
        _TeamStats(flag: '🇶🇦', name: 'Qatar',        played: 3, won: 0, drawn: 0, lost: 3, gf: 1, ga: 7,  pts: 0),
      ],
    ),
    ScrollableSubgroupsData(
      title: 'GROUP B',
      subGroups: [
        _TeamStats(flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', name: 'England',  played: 3, won: 1, drawn: 2, lost: 0, gf: 9, ga: 2, pts: 5),
        _TeamStats(flag: '🇺🇸', name: 'USA',          played: 3, won: 1, drawn: 2, lost: 0, gf: 2, ga: 1,  pts: 5),
        _TeamStats(flag: '🇮🇷', name: 'Iran',         played: 3, won: 1, drawn: 0, lost: 2, gf: 4, ga: 7,  pts: 3),
        _TeamStats(flag: '🏴󠁧󠁢󠁷󠁬󠁳󠁿', name: 'Wales',   played: 3, won: 0, drawn: 1, lost: 2, gf: 1, ga: 6, pts: 1),
      ],
    ),
    ScrollableSubgroupsData(
      title: 'GROUP C',
      subGroups: [
        _TeamStats(flag: '🇦🇷', name: 'Argentina',    played: 3, won: 2, drawn: 0, lost: 1, gf: 5, ga: 2,  pts: 6),
        _TeamStats(flag: '🇵🇱', name: 'Poland',       played: 3, won: 1, drawn: 1, lost: 1, gf: 2, ga: 2,  pts: 4),
        _TeamStats(flag: '🇲🇽', name: 'Mexico',       played: 3, won: 1, drawn: 1, lost: 1, gf: 2, ga: 3,  pts: 4),
        _TeamStats(flag: '🇸🇦', name: 'Saudi Arabia', played: 3, won: 1, drawn: 0, lost: 2, gf: 3, ga: 5,  pts: 3),
      ],
    ),
    ScrollableSubgroupsData(
      title: 'GROUP D',
      subGroups: [
        _TeamStats(flag: '🇫🇷', name: 'France',       played: 3, won: 2, drawn: 0, lost: 1, gf: 6, ga: 2,  pts: 6),
        _TeamStats(flag: '🇦🇺', name: 'Australia',    played: 3, won: 2, drawn: 0, lost: 1, gf: 5, ga: 6,  pts: 6),
        _TeamStats(flag: '🇩🇰', name: 'Denmark',      played: 3, won: 0, drawn: 2, lost: 1, gf: 1, ga: 2,  pts: 2),
        _TeamStats(flag: '🇹🇳', name: 'Tunisia',      played: 3, won: 0, drawn: 2, lost: 1, gf: 1, ga: 3,  pts: 2),
      ],
    ),
    ScrollableSubgroupsData(
      title: 'GROUP E',
      subGroups: [
        _TeamStats(flag: '🇯🇵', name: 'Japan',        played: 3, won: 2, drawn: 0, lost: 1, gf: 4, ga: 3,  pts: 6),
        _TeamStats(flag: '🇪🇸', name: 'Spain',        played: 3, won: 1, drawn: 1, lost: 1, gf: 9, ga: 3,  pts: 4),
        _TeamStats(flag: '🇩🇪', name: 'Germany',      played: 3, won: 1, drawn: 1, lost: 1, gf: 6, ga: 5,  pts: 4),
        _TeamStats(flag: '🇨🇷', name: 'Costa Rica',   played: 3, won: 1, drawn: 0, lost: 2, gf: 3, ga: 11, pts: 3),
      ],
    ),
    ScrollableSubgroupsData(
      title: 'GROUP F',
      subGroups: [
        _TeamStats(flag: '🇲🇦', name: 'Morocco',      played: 3, won: 2, drawn: 1, lost: 0, gf: 4, ga: 1,  pts: 7),
        _TeamStats(flag: '🇭🇷', name: 'Croatia',      played: 3, won: 1, drawn: 2, lost: 0, gf: 4, ga: 1,  pts: 5),
        _TeamStats(flag: '🇧🇪', name: 'Belgium',      played: 3, won: 1, drawn: 1, lost: 1, gf: 1, ga: 2,  pts: 4),
        _TeamStats(flag: '🇨🇦', name: 'Canada',       played: 3, won: 0, drawn: 0, lost: 3, gf: 2, ga: 7,  pts: 0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _data = List.from(_initialData.map(
      (g) => ScrollableSubgroupsData<_TeamStats>(
        title: g.title,
        subGroups: List.from(g.subGroups),
      ),
    ));
  }

  /// Begins the dismiss animation for [team], then removes it from [_data].
  void _dismissTeam(_TeamStats team) {
    setState(() => _dismissing.add(team.name));
  }

  /// Called after the dismiss animation completes — removes the item from state.
  void _onDismissed(_TeamStats team) {
    setState(() {
      _dismissing.remove(team.name);
      for (final group in _data) {
        group.subGroups.remove(team);
      }
      _data.removeWhere((g) => g.subGroups.isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Scrollable Subgroups',
      backgroundColor: const Color(0xFFF0F0F0),
      description:
          'Scrollable list with sticky headers built on Slivers. '
          'Tap any team to trigger a scroll-driven dismiss animation. '
          'World Cup 2022 group stage standings.',
      infoItems: const [
        'Built on SliverPersistentHeader + SliverMainAxisGroup.',
        'Sticky group headers pin to top while scrolling.',
        'Tap-to-dismiss with scroll-driven slide + size animation.',
        'Grouped card style with top/bottom corner radius.',
        'Generic <T> API — works with any data model.',
      ],
      codeSnippet: '''ScrollableSubgroups<TeamStats>(
  data: groups,
  style: ScrollableSubgroupsStyle(
    headerBackgroundColor: Color(0xFF1A1A2E),
    groupSpacing: 20,
  ),
  onChanged: (team) => _dismiss(team),
  itemBuilder: (context, team) => StandingsRow(team: team),
)''',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ScrollableSubgroups<_TeamStats>(
          data: _data,
          style: const ScrollableSubgroupsStyle(
            // White background — same as the card rows.
            headerBackgroundColor: Colors.white,
            headerTextStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
            headerPadding: EdgeInsets.symmetric(horizontal: 16),
            groupSpacing: 16,
            headerHeight: 48,
            // Top corners on each group's sticky header.
            headerTopBorderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            scaffoldBackgroundColor: Color(0xFFF0F0F0),
          ),
          // Column header row — separate from the group title, scrolls with content.
          prefixItemBuilder: (context, group) => _ColumnHeaderRow(),
          onChanged: _dismissTeam,
          itemBuilder: (context, team) {
            final groupData =
                _data.firstWhere((g) => g.subGroups.contains(team));
            final index = groupData.subGroups.indexOf(team);
            final isFirst = index == 0;
            final activeTeams = groupData.subGroups
                .where((t) => !_dismissing.contains(t.name))
                .toList();
            final isLast = activeTeams.isNotEmpty
                ? team == activeTeams.last
                : index == groupData.subGroups.length - 1;

            return _DismissibleTeamRow(
              key: ValueKey(team.name),
              team: team,
              isFirst: isFirst,
              isLast: isLast,
              isDismissing: _dismissing.contains(team.name),
              onDismissed: () => _onDismissed(team),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dismissible row with scroll-driven animation
// ---------------------------------------------------------------------------

/// A stateful row that animates itself scrolling upward and fading out
/// when [isDismissing] flips to true.
class _DismissibleTeamRow extends StatefulWidget {
  final _TeamStats team;
  final bool isFirst;
  final bool isLast;
  final bool isDismissing;
  final VoidCallback onDismissed;

  const _DismissibleTeamRow({
    super.key,
    required this.team,
    required this.isFirst,
    required this.isLast,
    required this.isDismissing,
    required this.onDismissed,
  });

  @override
  State<_DismissibleTeamRow> createState() => _DismissibleTeamRowState();
}

class _DismissibleTeamRowState extends State<_DismissibleTeamRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    // Slide upward — mimics being scrolled away.
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInCubic),
    ));

    // Fade out simultaneously.
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Collapse height after the slide — the "space closes up" effect.
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_DismissibleTeamRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDismissing && !oldWidget.isDismissing) {
      _controller.forward().then((_) {
        if (mounted) widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTop2 = widget.isFirst ||
        (_data(context).firstWhere(
              (g) => g.subGroups.contains(widget.team),
              orElse: () => ScrollableSubgroupsData(
                  title: '', subGroups: [widget.team]),
            ).subGroups.indexOf(widget.team) ==
            1);

    final radius = BorderRadius.only(
      topLeft:     widget.isFirst ? const Radius.circular(0) : Radius.zero,
      topRight:    widget.isFirst ? const Radius.circular(0) : Radius.zero,
      bottomLeft:  widget.isLast  ? const Radius.circular(16) : Radius.zero,
      bottomRight: widget.isLast  ? const Radius.circular(16) : Radius.zero,
    );

    return ClipRRect(
      borderRadius: radius,
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axisAlignment: -1.0,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Qualification indicator bar
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isTop2
                          ? const Color(0xFF00C853)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.team.flag,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  // Team name — left-aligned, expands to fill space.
                  Expanded(
                    child: Text(
                      widget.team.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  // Stat values only — labels are in the sticky header.
                  _StatValue('${widget.team.played}'),
                  _StatValue('${widget.team.won}'),
                  _StatValue('${widget.team.drawn}'),
                  _StatValue('${widget.team.lost}'),
                  _StatValue(
                    widget.team.gd >= 0
                        ? '+${widget.team.gd}'
                        : '${widget.team.gd}',
                    colored: true,
                    positive: widget.team.gd >= 0,
                  ),
                  const SizedBox(width: 4),
                  // Points badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isTop2
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.team.pts}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isTop2
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to access the live data from ancestor state.
  List<ScrollableSubgroupsData<_TeamStats>> _data(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _ScrollableSubgroupsShowcaseState>();
    return state?._data ?? [];
  }
}

// ---------------------------------------------------------------------------
// Stat value widget (value only — label is in the sticky header)
// ---------------------------------------------------------------------------

class _StatValue extends StatelessWidget {
  final String value;
  final bool colored;
  final bool positive;

  const _StatValue(
    this.value, {
    this.colored = false,
    this.positive = true,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = const Color(0xFF888888);
    if (colored) {
      textColor =
          positive ? const Color(0xFF00C853) : const Color(0xFFFF3B30);
    }
    return SizedBox(
      width: 28,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column header row — rendered once per group via prefixItemBuilder.
// Separate from the sticky group title header.
// ---------------------------------------------------------------------------

/// A single row showing column labels (Team, P, W, D, L, GD, PTS),
/// rendered with a white background to match the card rows.
class _ColumnHeaderRow extends StatelessWidget {
  const _ColumnHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: const [
          // Spacer matching: indicator bar (3) + gap (10) + flag (22) + gap (10)
          SizedBox(width: 45),
          // "Team" label — expands to fill left side.
          Expanded(
            child: Text(
              'Team',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAAAAAA),
                letterSpacing: 0.5,
              ),
            ),
          ),
          _ColLabel('P'),
          _ColLabel('W'),
          _ColLabel('D'),
          _ColLabel('L'),
          _ColLabel('GD'),
          SizedBox(width: 4),
          _ColLabel('PTS', width: 32),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  final String label;
  final double width;

  const _ColLabel(this.label, {this.width = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

