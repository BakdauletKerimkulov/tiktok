// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

typedef VideoModelId = String;

class VideoModel extends Equatable {
  const VideoModel({required this.id, required this.url});
  final VideoModelId id;
  final String url;

  @override
  List<Object?> get props => [id, url];
}
