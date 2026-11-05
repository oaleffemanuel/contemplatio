import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../data/content_repository.dart';
import '../widgets/liquid_tab_bar.dart';
import '../widgets/lumen_icons.dart';
import 'home_screen.dart';
import 'rosary_sets_screen.dart';
import 'settings_screen.dart';
import 'via_sacra_screen.dart';

/// Início · Rosário · Via Sacra · Ajustes under a liquid-glass tab bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});

  final ContentRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  final _scrolls = List.generate(4, (_) => ScrollController());

  @override
  void dispose() {
    for (final c in _scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  /// Tapping the open tab again brings its list back to the top.
  void _scrollToTop(int tab) {
    final c = _scrolls[tab];
    if (c.hasClients && c.offset > 0) {
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  static Widget Function(Color) _fi(IconData icon) =>
      (c) => Icon(icon, color: c, size: 26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(
            repository: widget.repository,
            scrollController: _scrolls[0],
            onOpenTab: (i) => setState(() => _tab = i),
          ),
          RosarySetsScreen(
            repository: widget.repository,
            scrollController: _scrolls[1],
          ),
          ViaSacraScreen(
            repository: widget.repository,
            scrollController: _scrolls[2],
          ),
          SettingsScreen(
            repository: widget.repository,
            scrollController: _scrolls[3],
          ),
        ],
      ),
      bottomNavigationBar: LiquidTabBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onReselect: _scrollToTop,
        tabs: [
          LiquidTab(
            label: 'Início',
            icon: _fi(FluentIcons.home_24_regular),
            selectedIcon: _fi(FluentIcons.home_24_filled),
          ),
          LiquidTab(
            label: 'Mistérios',
            icon: (c) => RosaryIcon(color: c, size: 26),
            selectedIcon: (c) => RosaryIcon(color: c, size: 26, filled: true),
          ),
          LiquidTab(
            label: 'Via Sacra',
            icon: (c) => CrossIcon(color: c, size: 26),
            selectedIcon: (c) => CrossIcon(color: c, size: 26, filled: true),
          ),
          LiquidTab(
            label: 'Ajustes',
            icon: _fi(FluentIcons.settings_24_regular),
            selectedIcon: _fi(FluentIcons.settings_24_filled),
          ),
        ],
      ),
    );
  }
}
