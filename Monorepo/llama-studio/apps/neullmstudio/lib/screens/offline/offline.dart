import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neu_llm_studio/infrastructure/llama_provider.dart';

class Offline extends StatefulWidget {
  const Offline({super.key});

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  SystemStat? _stat;
  HealthStatus? _health;
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final results = await Future.wait([
        LlamaProvider().getSystemData(),
        LlamaProvider().getHealth(),
      ]);
      if (!mounted) return;
      setState(() {
        _stat = results[0] as SystemStat;
        _health = results[1] as HealthStatus?;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Cannot reach server at ${AppConfig.baseUrl}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _loading = true);
              _refresh();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: () {
                  setState(() => _loading = true);
                  _refresh();
                })
              : _DashboardBody(stat: _stat!, health: _health),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.errorContainer,
              child: Icon(Icons.cloud_off_outlined, size: 40, color: cs.error),
            ),
            const SizedBox(height: 20),
            Text('Server Unreachable', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard body ────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final SystemStat stat;
  final HealthStatus? health;

  const _DashboardBody({required this.stat, this.health});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ServerStatusCard(health: health),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.memory_rounded,
          label: 'CPU Usage',
          value: '${stat.cpuPercentage}%',
          progress: stat.cpuValue / 100,
          context: context,
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.developer_board_rounded,
          label: 'Memory',
          value: '${stat.ramUsed} / ${stat.ramTotal}',
          subtitle: '${stat.ramAvailable} available',
          progress: stat.ramPercent,
          context: context,
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.storage_rounded,
          label: 'Disk',
          value: '${stat.diskUsed} / ${stat.diskTotal}',
          subtitle: '${stat.diskAvailable} available',
          progress: stat.diskPercent,
          context: context,
        ),
        const SizedBox(height: 12),
        _ModelCard(modelLoaded: health?.modelLoaded ?? false),
      ],
    );
  }
}

// ── Server status card ────────────────────────────────────────────────────────

class _ServerStatusCard extends StatelessWidget {
  final HealthStatus? health;

  const _ServerStatusCard({this.health});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final online = health != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? const Color(0xFF34A853) : cs.error,
                boxShadow: [
                  BoxShadow(
                    color: (online ? const Color(0xFF34A853) : cs.error).withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    online ? 'Server Online' : 'Server Offline',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    AppConfig.baseUrl,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (online)
              Chip(
                label: const Text('Connected'),
                padding: EdgeInsets.zero,
                labelStyle: tt.labelSmall?.copyWith(color: const Color(0xFF34A853)),
                side: const BorderSide(color: Color(0xFF34A853)),
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final double progress;
  final BuildContext context;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.progress,
    required this.context,
  });

  Color _barColor(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (progress > 0.9) return cs.error;
    if (progress > 0.7) return Colors.orange;
    return cs.primary;
  }

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    final tt = Theme.of(ctx).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: tt.labelMedium?.copyWith(color: _barColor(ctx)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor(ctx)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model card ────────────────────────────────────────────────────────────────

class _ModelCard extends StatelessWidget {
  final bool modelLoaded;

  const _ModelCard({required this.modelLoaded});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.psychology_rounded, size: 28, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CodeLlama-7B-Instruct',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'GGUF Q2_K · ~3.9 GB',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: modelLoaded
                    ? const Color(0xFF34A853).withValues(alpha: 0.12)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: modelLoaded ? const Color(0xFF34A853) : cs.outline,
                ),
              ),
              child: Text(
                modelLoaded ? 'Loaded' : 'Idle',
                style: tt.labelMedium?.copyWith(
                  color: modelLoaded ? const Color(0xFF34A853) : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
