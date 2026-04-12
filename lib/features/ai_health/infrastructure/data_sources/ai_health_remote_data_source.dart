import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mobile_app/core/config/env_config.dart';
import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/ai_health/infrastructure/models/ai_status_model.dart';

/// Kontrak akses remote AI health.
abstract class AiHealthRemoteDataSource {
  /// Ambil snapshot status AI satu kali via REST.
  Future<AiStatusModel> getCurrentStatus();

  /// Stream status AI via SSE (Server-Sent Events).
  Stream<AiStatusModel> streamStatus();
}

class AiHealthRemoteDataSourceImpl implements AiHealthRemoteDataSource {
  AiHealthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // ── REST ──────────────────────────────────────────────────────────────────

  @override
  Future<AiStatusModel> getCurrentStatus() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.aiStatusCurrent,
    );

    _assertSuccess(response);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons AI status kosong dari server.',
      );
    }

    return AiStatusModel.fromJson(data);
  }

  // ── SSE ───────────────────────────────────────────────────────────────────

  /// Stream SSE dari `GET /ai/status`.
  ///
  /// Menggunakan Dio `ResponseType.stream` untuk membaca byte-by-byte.
  /// SSE format: setiap event dipisahkan oleh `\n\n`, tiap baris `data: {...}`.
  ///
  /// Stream ini akan terus berjalan sampai server menutup koneksi atau
  /// subscriber melakukan cancel.
  @override
  Stream<AiStatusModel> streamStatus() async* {
    // final streamController = StreamController<AiStatusModel>();

    // SSE butuh timeout yang panjang — override receiveTimeout
    final options = Options(
      responseType: ResponseType.stream,
      headers: {
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
      receiveTimeout: const Duration(hours: 1),
    );

    // Bangun URL lengkap agar tidak bergantung pada baseUrl ApiClient
    final url =
        '${EnvConfig.apiBaseUrl}${ApiEndpoints.aiStatusStream}';

    Response<ResponseBody>? response;

    try {
      response = await _apiClient.raw.get<ResponseBody>(url, options: options);
    } on DioException catch (e) {
      throw ServerException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal membuka koneksi SSE.',
      );
    }

    final byteStream = response.data?.stream;
    if (byteStream == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Stream SSE tidak tersedia.',
      );
    }

    // Buffer untuk menampung data yang belum lengkap antar chunks
    final buffer = StringBuffer();

    await for (final bytes in byteStream) {
      buffer.write(utf8.decode(bytes, allowMalformed: true));

      // SSE event dipisahkan oleh blank line (\n\n)
      final raw = buffer.toString();
      final parts = raw.split('\n\n');

      // Bagian terakhir mungkin belum lengkap — simpan di buffer
      buffer.clear();
      final incomplete = raw.endsWith('\n\n') ? '' : parts.removeLast();
      if (incomplete.isNotEmpty) buffer.write(incomplete);

      for (final eventBlock in parts) {
        final model = _parseSseBlock(eventBlock);
        if (model != null) yield model;
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Parse satu blok SSE (beberapa baris sampai blank line) ke [AiStatusModel].
  ///
  /// Hanya memproses baris `data: ...`. Baris `event:`, `id:`, `retry:` diabaikan.
  AiStatusModel? _parseSseBlock(String block) {
    if (block.trim().isEmpty) return null;

    for (final line in block.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) continue;

      final jsonStr = trimmed.substring('data:'.length).trim();
      if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return AiStatusModel.fromJson(json);
      } catch (_) {
        // Abaikan baris yang tidak valid JSON
        continue;
      }
    }

    return null;
  }

  /// Periksa status HTTP response secara manual karena ApiClient
  /// menggunakan `validateStatus: status < 500` (4xx tidak auto-throw).
  void _assertSuccess(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      final data = response.data;
      final rawMessage = data is Map ? data['message'] : null;
      final String message = switch (rawMessage) {
        List()   => (rawMessage as List).join(', '),
        String() => rawMessage as String,
        _        => 'AI status tidak tersedia (HTTP $statusCode).',
      };
      throw ServerException(statusCode: statusCode, message: message);
    }
  }
}
