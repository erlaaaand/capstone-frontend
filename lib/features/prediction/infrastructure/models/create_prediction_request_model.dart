/// Request body untuk endpoint `POST /predictions`.
///
/// Gambar harus sudah diupload terlebih dahulu via `POST /storage/upload`.
///
/// Format JSON:
/// ```json
/// {
///   "imageUrl": "https://...",
///   "fileKey": "predictions/userId/abc.jpg"
/// }
/// ```
class CreatePredictionRequestModel {
  const CreatePredictionRequestModel({
    required this.imageUrl,
    required this.fileKey,
  });

  /// URL publik gambar hasil upload.
  final String imageUrl;

  /// Key file di storage (digunakan backend untuk referensi).
  final String fileKey;

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'fileKey': fileKey,
      };
}
