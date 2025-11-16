import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
  });

  // convert a firestore document to a post
  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?) ?? Timestamp.now(),
      likeCount: data['likeCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  // convert a post object to map

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likedBy': likedBy,
    };
  }
}
