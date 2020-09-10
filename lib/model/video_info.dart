import 'package:cloud_firestore/cloud_firestore.dart';

class VideoInfo {
  String uploaderUid;
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;
  int views;
  int likes;
  int shares;
  int rating;
  int comments;

  VideoInfo(
      {this.uploaderUid,
        this.videoUrl,
      this.thumbUrl,
      this.coverUrl,
      this.aspectRatio,
      this.uploadedAt,
      this.videoName,
      this.views,
      this.likes,
      this.shares,
      this.rating,
      this.comments});

  static fromDocument(QueryDocumentSnapshot ds) {
    return VideoInfo(
      videoUrl: ds.data()['videoUrl'],
      thumbUrl: ds.data()['thumbUrl'],
      coverUrl: ds.data()['coverUrl'],
      aspectRatio: ds.data()['aspectRatio'],
      videoName: ds.data()['videoName'],
      uploadedAt: ds.data()['uploadedAt'],
    );
  }
}
