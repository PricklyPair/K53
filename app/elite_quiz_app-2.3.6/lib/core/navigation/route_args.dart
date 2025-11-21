/// Base class for all screen arguments.
///
/// This abstract class serves as a foundation for all screen-specific argument classes.
/// Each screen that requires arguments should create its own class that extends this.
///
/// Example:
/// ```dart
/// // For a detail screen
/// final class DetailScreenArgs extends RouteArgs {
///   const DetailScreenArgs({
///     required this.id,
///     required this.title,
///   });
///
///   final String id;
///   final String title;
/// }
/// ```
abstract base class RouteArgs {
  const RouteArgs();
}
