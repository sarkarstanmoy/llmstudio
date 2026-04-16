import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neu_llm_studio/infrastructure/llama_provider.dart';
import 'package:neu_llm_studio/themes/custom_theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _selectedModel = 'codellama-7b-instruct';
  double _temperature = 0.1;
  int _maxTokens = 256;
  late final TextEditingController _urlController =
      TextEditingController(text: AppConfig.baseUrl);

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Server ────────────────────────────────────────────────────────
          const _SectionLabel('SERVER'),
          Card(
            child: ListTile(
              leading: Icon(Icons.link_rounded, color: cs.primary),
              title: const Text('API Endpoint'),
              subtitle: Text(
                AppConfig.baseUrl,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showUrlDialog(context),
            ),
          ),

          const SizedBox(height: 20),

          // ── Model ─────────────────────────────────────────────────────────
          const _SectionLabel('MODEL'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.psychology_rounded, color: cs.primary),
                  title: const Text('Active Model'),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedModel,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(
                          value: 'codellama-7b-instruct',
                          child: Text('CodeLlama 7B'),
                        ),
                        DropdownMenuItem(
                          value: 'llama-7b-chat',
                          child: Text('Llama 7B Chat'),
                        ),
                        DropdownMenuItem(
                          value: 'llama-13b-chat',
                          child: Text('Llama 13B Chat'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedModel = v!),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.thermostat_rounded, color: cs.primary),
                  title: const Text('Temperature'),
                  subtitle: Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: _temperature.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                  trailing: SizedBox(
                    width: 36,
                    child: Text(
                      _temperature.toStringAsFixed(1),
                      style: tt.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.format_list_numbered_rounded, color: cs.primary),
                  title: const Text('Max Tokens'),
                  subtitle: Slider(
                    value: _maxTokens.toDouble(),
                    min: 64,
                    max: 1024,
                    divisions: 15,
                    label: '$_maxTokens',
                    onChanged: (v) => setState(() => _maxTokens = v.round()),
                  ),
                  trailing: SizedBox(
                    width: 36,
                    child: Text(
                      '$_maxTokens',
                      style: tt.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Appearance ────────────────────────────────────────────────────
          const _SectionLabel('APPEARANCE'),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                Get.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: cs.primary,
              ),
              title: const Text('Dark Mode'),
              value: Get.isDarkMode,
              onChanged: (_) {
                Get.changeTheme(
                  Get.isDarkMode
                      ? CustomTheme().buildLightTheme()
                      : CustomTheme().buildDarkTheme(),
                );
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────────────
          const _SectionLabel('ABOUT'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                  title: const Text('LLM Studio'),
                  subtitle: const Text('Version 0.1.0'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.model_training_rounded, color: cs.primary),
                  title: const Text('Runtime'),
                  subtitle: const Text('llama-cpp-python · FastAPI · Python 3.9'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.source_rounded, color: cs.primary),
                  title: const Text('Repository'),
                  subtitle: const Text('github.com/sarkarstanmoy/llmstudio'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showUrlDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Endpoint'),
        content: TextField(
          controller: _urlController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'http://127.0.0.1:4557',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() => AppConfig.baseUrl = url);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
