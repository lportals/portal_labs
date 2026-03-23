
/// A model representing a subscription pricing plan.
class PricingPlan {
  /// Unique identifier for the plan.
  final String id;

  /// The title of the plan (e.g., 'Free', 'Starter', 'Pro').
  final String title;

  /// The price of the plan for the given period.
  final double price;

  /// The text displayed for the period (e.g., 'month', 'year').
  final String periodText;

  /// Whether this plan is marked as a popular choice.
  final bool isPopular;

  /// Custom text for the popular badge. Defaults to 'Popular'.
  final String badgeText;

  const PricingPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.periodText,
    this.isPopular = false,
    this.badgeText = 'Popular',
  });
}

/// Supported pricing periods for the picker.
enum PricingPeriod { monthly, yearly }
