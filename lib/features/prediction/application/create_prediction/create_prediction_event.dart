import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class CreatePredictionEvent extends Equatable {
  const CreatePredictionEvent();
}

/// User memilih gambar dan memulai proses scan.
///
/// Alur yang dipicu:
/// 1. Upload gambar (Uploading state)
/// 2. Buat record prediksi PENDING (Processing state)
/// 3. Poll hingga SUCCESS / FAILED
final class CreatePredictionStarted extends CreatePredictionEvent {
  const CreatePredictionStarted(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile.path];
}

/// Timer polling minta cek status prediksi.
///
/// Dikirim secara periodik oleh [CreatePredictionBloc._startPolling].
final class CreatePredictionPolled extends CreatePredictionEvent {
  const CreatePredictionPolled(this.predictionId);

  final String predictionId;

  @override
  List<Object?> get props => [predictionId];
}

/// Reset state ke [CreatePredictionInitial] dan batalkan polling aktif.
///
/// Dikirim saat user menekan "Scan Lagi" atau navigasi keluar.
final class CreatePredictionReset extends CreatePredictionEvent {
  const CreatePredictionReset();

  @override
  List<Object?> get props => [];
}
