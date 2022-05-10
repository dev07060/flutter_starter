import 'package:flutter/material.dart';

class VideoDataModel {
  final String factor;
  final String title;
  final int category;
  final String thumbnail;

  const VideoDataModel(
      {required this.factor,
      required this.title,
      required this.category,
      required this.thumbnail});

  factory VideoDataModel.turnSnapshotIntoListRecord(Map data) {
    return VideoDataModel(
      factor: data['factor'],
      title: data['title'],
      category: data['category'],
      thumbnail: data['thumbnail'],
    );
  }

  List<Object> get props => [factor, title, category, thumbnail];
}
