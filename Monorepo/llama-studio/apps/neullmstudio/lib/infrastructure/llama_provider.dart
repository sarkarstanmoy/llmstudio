import 'dart:convert';
import 'package:dio/dio.dart';

/// Global server configuration — can be changed from Settings at runtime.
class AppConfig {
  static String baseUrl = 'http://127.0.0.1:4557';
}

class HealthStatus {
  final bool ok;
  final bool modelLoaded;

  const HealthStatus({required this.ok, required this.modelLoaded});

  factory HealthStatus.fromJson(Map<String, dynamic> data) => HealthStatus(
        ok: data['status'] == 'ok',
        modelLoaded: data['model_loaded'] as bool? ?? false,
      );
}

class SystemStat {
  final String ramAvailable;
  final String ramTotal;
  final String ramUsed;
  final String cpuPercentage;
  final String diskAvailable;
  final String diskTotal;
  final String diskPercentage;
  final String diskUsed;

  const SystemStat({
    required this.ramAvailable,
    required this.ramTotal,
    required this.ramUsed,
    required this.cpuPercentage,
    required this.diskAvailable,
    required this.diskTotal,
    required this.diskPercentage,
    required this.diskUsed,
  });

  factory SystemStat.fromJson(Map<String, dynamic> data) => SystemStat(
        ramAvailable: data['ram_available'] as String,
        ramTotal: data['ram_total'] as String,
        ramUsed: data['ram_used'] as String,
        cpuPercentage: data['cpu_percentage'] as String,
        diskAvailable: data['disk_available'] as String,
        diskTotal: data['disk_total'] as String? ?? '0 GB',
        diskPercentage: data['disk_percentage'] as String,
        diskUsed: data['disk_used'] as String,
      );

  // ── Computed helpers ──────────────────────────────────────────────────────

  double get cpuValue => double.tryParse(cpuPercentage) ?? 0.0;

  double get ramUsedGb => _parseGb(ramUsed);
  double get ramTotalGb => _parseGb(ramTotal);
  double get ramPercent => ramTotalGb > 0 ? (ramUsedGb / ramTotalGb).clamp(0.0, 1.0) : 0.0;

  double get diskUsedGb => _parseGb(diskUsed);
  double get diskTotalGb => _parseGb(diskTotal);
  double get diskPercent => diskTotalGb > 0 ? (diskUsedGb / diskTotalGb).clamp(0.0, 1.0) : 0.0;

  double _parseGb(String s) => double.tryParse(s.replaceAll(' GB', '').trim()) ?? 0.0;
}

class LlamaProvider {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<HealthStatus?> getHealth() async {
    try {
      final res = await _dio.get('${AppConfig.baseUrl}/health');
      return HealthStatus.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String> getResponse(String prompt) async {
    final res = await _dio.post(
      '${AppConfig.baseUrl}/prompt/',
      data: jsonEncode({'request': prompt}),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return res.data as String;
  }

  Future<SystemStat> getSystemData() async {
    final res = await _dio.get('${AppConfig.baseUrl}/systemstats');
    return SystemStat.fromJson(res.data as Map<String, dynamic>);
  }
}
