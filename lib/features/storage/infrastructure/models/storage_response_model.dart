/// Model respons dari endpoint `POST /storage/upload`.
///
/// Format JSON dari NestJS:
/// ```json
/// {
///   "fileKey":      "predictions/userId/abc123.jpg",
///   "url":          "http://localhost:3000/uploads/predictions/userId/abc123.jpg",
///   "originalName": "durian_photo.jpg",
///   "mimeType":     "image/jpeg",
///   "size":         204800
/// }
/// ```
class StorageResponseModel {
  const StorageResponseModel({
    required this.fileKey,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.size,
  });

  final String fileKey;
  final String url;
  final String originalName;
  final String mimeType;
  final int size;

  factory StorageResponseModel.fromJson(Map<String, dynamic> json) {
    return StorageResponseModel(
      fileKey: json['fileKey'] as String,
      url: json['url'] as String,
      originalName: json['originalName'] as String,
      mimeType: json['mimeType'] as String,
      // Beberapa backend mengirim size sebagai String, handle keduanya.
      size: switch (json['size']) {
        int s    => s,
        String s => int.tryParse(s) ?? 0,
        _        => 0,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'fileKey': fileKey,
        'url': url,
        'originalName': originalName,
        'mimeType': mimeType,
        'size': size,
      };

  @override
  String toString() =>
      'StorageResponseModel(fileKey: $fileKey, originalName: $originalName, '
      'size: $size)';
}
