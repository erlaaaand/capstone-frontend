class CreatePredictionRequestModel {
  const CreatePredictionRequestModel({
    required this.imageUrl,
    // required this.fileKey,
  });

  final String imageUrl;

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
      };
}
