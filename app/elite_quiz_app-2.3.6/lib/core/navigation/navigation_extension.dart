import 'package:flutter/material.dart';
import 'package:flutterquiz/core/navigation/route_args.dart';

/// Navigation utilities with type-safe argument handling.
extension NavigationExtension on BuildContext {
  /// Pops the current route.
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Whether the current route can be popped.
  bool get canPop => Navigator.of(this).canPop();

  /// Pops the current route if the navigator stack allows it.
  void shouldPop<T extends Object?>([T? result]) {
    if (canPop) {
      pop<T>(result);
    }
  }

  /// Pushes a named route with type-safe arguments.
  ///
  /// Returns a [Future] that completes when the pushed route is popped.
  Future<T?> pushNamed<T extends Object?, A extends RouteArgs>(
    String routeName, {
    A? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces the current route with a named route.
  ///
  /// The [result] is returned to the route that was below the replaced route.
  Future<T?> pushReplacementNamed<
    T extends Object?,
    TO extends Object?,
    A extends RouteArgs
  >(String routeName, {A? arguments, TO? result}) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Pushes a named route and removes all previous routes.
  ///
  /// The [predicate] determines which routes to keep. Defaults to removing all routes.
  Future<T?> pushNamedAndRemoveUntil<T extends Object?, A extends RouteArgs>(
    String routeName, {
    A? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pushes a route object.
  ///
  /// Returns a [Future] that completes when the pushed route is popped.
  Future<T?> push<T extends Object?>(Route<T> route) {
    return Navigator.of(this).push<T>(route);
  }

  /// Replaces the current route with a new route.
  ///
  /// The [result] is returned to the route that was below the replaced route.
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> route, {
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(route, result: result);
  }

  /// Pushes a route and removes all previous routes.
  ///
  /// The [predicate] determines which routes to keep. Defaults to removing all routes.
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> route, {
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(
      this,
    ).pushAndRemoveUntil<T>(route, predicate ?? (route) => false);
  }
}

/// Route settings utilities for type-safe argument extraction.
extension RouteSettingsExtension on RouteSettings {
  /// Extracts route arguments with compile-time type safety.
  ///
  /// Throws an assertion error in debug mode if arguments are null
  /// or not of the expected type.
  T args<T extends RouteArgs>() {
    assert(arguments != null, 'Expected $T, Route arguments are null');
    assert(arguments is T, 'Expected $T, got ${arguments.runtimeType}');
    return arguments! as T;
  }
}
