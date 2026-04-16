import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neu_llm_studio/screens/localserver/local-server.dart';
import 'package:neu_llm_studio/screens/localserver/localserver-web.dart';
import 'package:neu_llm_studio/screens/offline/offline.dart';
import 'package:neu_llm_studio/screens/settings/settings.dart';
import 'package:neu_llm_studio/screens/test/test.dart';
import 'package:neu_llm_studio/themes/custom_theme.dart';
import '../../common/globals.dart' as globals;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1; // Chat tab open by default

  static const _navItems = [
    _NavItem(icon: Icons.monitor_heart_outlined, selectedIcon: Icons.monitor_heart, label: 'Dashboard'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, selectedIcon: Icons.chat_bubble_rounded, label: 'Chat'),
    _NavItem(icon: Icons.dns_outlined, selectedIcon: Icons.dns_rounded, label: 'Server'),
    _NavItem(icon: Icons.tune_outlined, selectedIcon: Icons.tune_rounded, label: 'Settings'),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const Offline();
      case 1:
        return const Test();
      case 2:
        return globals.isWeb ? const LocalServerWeb() : const LocalServer();
      case 3:
        return const Settings();
      default:
        return const Test();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;
    final isExtended = width >= 1000;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: isExtended,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              leading: _RailLeading(extended: isExtended),
              trailing: _RailTrailing(extended: isExtended),
              groupAlignment: -1.0,
              destinations: _navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
          if (isWide) const VerticalDivider(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _navItems
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ))
                  .toList(),
            ),
    );
  }
}

// ── Nav item descriptor ──────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// ── Rail leading: brand + theme toggle ──────────────────────────────────────

class _RailLeading extends StatelessWidget {
  final bool extended;
  const _RailLeading({required this.extended});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.psychology_rounded, size: 26, color: cs.onPrimaryContainer),
          ),
          if (extended) ...[
            const SizedBox(height: 8),
            Text(
              'LLM Studio',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}

// ── Rail trailing: theme toggle ──────────────────────────────────────────────

class _RailTrailing extends StatelessWidget {
  final bool extended;
  const _RailTrailing({required this.extended});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: extended
              ? TextButton.icon(
                  icon: Icon(Get.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  label: Text(Get.isDarkMode ? 'Light' : 'Dark'),
                  onPressed: _toggleTheme,
                )
              : IconButton(
                  icon: Icon(Get.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  tooltip: Get.isDarkMode ? 'Light mode' : 'Dark mode',
                  onPressed: _toggleTheme,
                ),
        ),
      ),
    );
  }

  void _toggleTheme() {
    Get.changeTheme(
      Get.isDarkMode ? CustomTheme().buildLightTheme() : CustomTheme().buildDarkTheme(),
    );
  }
}
