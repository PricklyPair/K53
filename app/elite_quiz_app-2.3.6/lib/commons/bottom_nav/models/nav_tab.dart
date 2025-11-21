import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/bottom_nav/models/nav_tab_type_enum.dart';

/// Represents a navigation tab in the dashboard.
///
/// Each tab is defined by its [tab] type, [title] for display
class NavTab {
  const NavTab({
    required this.tab,
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.child,
  });

  /// The [NavTabType] associated with this navigation item.
  final NavTabType tab;

  /// The title of the tab, used for localization.
  final String title;

  /// Asset path for the inactive state icon of the tab.
  final String icon;

  /// Asset path for the active state icon of the tab.
  final String activeIcon;

  final Widget child;
}
