import 'package:mobile_app/features/storage/domain/entities/uploaded_file.dart';
import 'package:mobile_app/features/storage/infrastructure/models/storage_response_model.dart';

/// Konversi [StorageResponseModel] (infrastructure) ↔ [UploadedFile] (domain).
///
/// Layer domain tidak boleh tahu tentang model — mapper ini menjadi
/// jembatan agar infrastruktur detail tidak bocor ke domain.
class StorageMapper {
  StorageMapper._();

  /// Model → Entity
  static UploadedFile toEntity(StorageResponseModel model) => UploadedFile(
        fileKey: model.fileKey,
        url: model.url,
        originalName: model.originalName,
        mimeType: model.mimeType,
        size: model.size,
      );

  /// Entity → Model (jarang dipakai, tapi tersedia untuk simetri)
  static StorageResponseModel toModel(UploadedFile entity) =>
      StorageResponseModel(
        fileKey: entity.fileKey,
        url: entity.url,
        originalName: entity.originalName,
        mimeType: entity.mimeType,
        size: entity.size,
      );
}
