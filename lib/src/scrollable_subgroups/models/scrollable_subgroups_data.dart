/// Data model representing a group of items under a shared header.
class ScrollableSubgroupsData<T> {
  /// Creates a [ScrollableSubgroupsData] container.
  const ScrollableSubgroupsData({
    required this.title,
    required this.subGroups,
  });

  /// The title displayed in the sticky header for this group.
  final String title;

  /// The list of items belonging to this subgroup.
  final List<T> subGroups;
}
