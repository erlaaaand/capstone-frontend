class CreatePredictionRequestModel {
  const CreatePredictionRequestModel({
    required this.imageUrl,
    required this.fileKey,
  });

  final String imageUrl;
  final String fileKey;

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'fileKey': fileKey,
      };
}
