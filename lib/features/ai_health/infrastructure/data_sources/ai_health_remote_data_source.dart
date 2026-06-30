import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mobile_app/core/config/env_config.dart';
import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/ai_health/infrastructure/models/ai_status_model.dart';

abstract class AiHealthRemoteDataSource {
  Future<AiStatusModel> getCurrentStatus();
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

  @override
  Stream<AiStatusModel> streamStatus() async* {
    final options = Options(
      responseType: ResponseType.stream,
      headers: {
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
      receiveTimeout: null,
    );

    final url = '${EnvConfig.apiBaseUrl}${ApiEndpoints.aiStatusStream}';

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

    final buffer = StringBuffer();

    await for (final bytes in byteStream) {
      buffer.write(utf8.decode(bytes, allowMalformed: true));

      final normalized = buffer
          .toString()
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');
      buffer.clear();

      final parts = normalized.split('\n\n');

      final incomplete = normalized.endsWith('\n\n') ? '' : parts.removeLast();
      if (incomplete.isNotEmpty) buffer.write(incomplete);

      for (final eventBlock in parts) {
        final model = _parseSseBlock(eventBlock);
        if (model != null) yield model;
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  AiStatusModel? _parseSseBlock(String block) {
    if (block.trim().isEmpty) return null;

    final dataBuffer = StringBuffer();

    for (final line in block.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) continue;

      final payloadStr = trimmed.substring('data:'.length).trim();
      if (payloadStr.isEmpty || payloadStr == '[DONE]') continue;
      
      dataBuffer.write(payloadStr);
    }

    final combinedJsonStr = dataBuffer.toString();
    if (combinedJsonStr.isEmpty) return null;

    try {
      final json = jsonDecode(combinedJsonStr) as Map<String, dynamic>;
      return AiStatusModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

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