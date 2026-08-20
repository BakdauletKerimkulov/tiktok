// ignore_for_file: public_member_api_docs, sort_constructors_first

typedef VideoModelId = String;

class VideoModel {
  const VideoModel({required this.id, required this.url});
  final VideoModelId id;
  final String url;
}
