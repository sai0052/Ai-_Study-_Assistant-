import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

/// The persistent app shell: wraps whichever tab is active with a shared
/// bottom navigation bar. Used as the "shell route" branch in GoRouter's
/// StatefulShellRoute, so each tab keeps its own navigation stack and
/// scroll position when switching tabs.
class MainShellScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainShellScreen({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(currentIndex: currentIndex, onTap: onTap),
    );
  }
}
