/// Represents a tag in the selection interaction.
class TagModel {

  /// Creates a new [TagModel].
  const TagModel({
    required this.id,
    required this.label,
  });
  /// The unique identifier for the tag.
  final String id;

  /// The text displayed on the tag.
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
