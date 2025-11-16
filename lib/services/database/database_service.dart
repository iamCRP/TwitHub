/*

DataBase Service
This class handles all the data from and to firebase

--------------------------------------------------------------------------------

- user profile
- post msg
- likes
- comments
- account stuff (report / block / delete account)
- follow / unfollow
- search users

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twithub/models/comment.dart';
import 'package:twithub/models/post.dart';
import 'package:twithub/models/user.dart';
import 'package:twithub/services/auth/auth_services.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Save user info
  Future<void> saveUserInfoFirebase({
    required String name,
    required String email,
  }) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final String username = email.split('@')[0];

      final UserProfile user = UserProfile(
        uid: uid,
        name: name,
        email: email,
        username: username,
        bio: '',
      );

      await _db.collection('Users').doc(uid).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      final userDoc = await _db.collection('Users').doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Update user bio
  Future<void> updateUserBioInFirebase(String bio) async {
    // get current uid
    String? uid = AuthService().getCurrentUid();
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  // Delete user account info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();

    //delete user doc
    DocumentReference userDoc = _db.collection('Users').doc(uid);
    batch.delete(userDoc);

    //delete user posts
    QuerySnapshot userPost = await _db
        .collection('Posts')
        .where('uid', isEqualTo: uid)
        .get();
    for (var post in userPost.docs) {
      batch.delete(post.reference);
    }

    //delete user comments
    QuerySnapshot userComments = await _db
        .collection('Comments')
        .where('uid', isEqualTo: uid)
        .get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }

    //delete user like
    QuerySnapshot allPosts = await _db.collection('Posts').get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likeBy'] as List<dynamic>? ?? [];
      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    //update follower & following records accordingly.. (later)
    //commit batch
    await batch.commit();
  }

  // Post Message
  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );
      Map<String, dynamic> newPostMap = newPost.toMap();
      await _db.collection('Posts').add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

  // Get all post
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete Post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Like post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;
      //doc for this post
      DocumentReference postDoc = _db.collection('Posts').doc(postId);
      await _db.runTransaction((transaction) async {
        //get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);
        //get like of user who like this post
        List<String> likeBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        //like count
        int currentLikeCount = postSnapshot['likeCount'];
        //if user has not liked this post yet -> then like
        if (!likeBy.contains(uid)) {
          //add user to like list
          likeBy.add(uid);
          //increment like count
          currentLikeCount++;
        } else {
          //remove user to like list
          likeBy.remove(uid);
          //decrement like count
          currentLikeCount--;
        }
        transaction.update(postDoc, {
          'likeCount': currentLikeCount,
          'likedBy': likeBy,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // Add comment to post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      //create a new comment
      Comment newComment = Comment(
        id: ' ',
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      //convert comment to map
      Map<String, dynamic> newCommentMap = newComment.toMap();

      //to store in firebase
      await _db.collection('Comments').add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  // Delete comment from post
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('Comments').doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Fetch comment for a post
  Future<List<Comment>> getCommentFromFirebase(String postId) async {
    try {
      //get comment from firebase
      QuerySnapshot snapshot = await _db
          .collection('Comments')
          .where('postId', isEqualTo: postId)
          .get();
      //return as a List of Comment
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Report Post
  Future<void> reportUserInFirebase(String postId, userId) async {
    final currentUserId = _auth.currentUser!.uid;

    //create report map
    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    //update in firestore
    await _db.collection('Reports').add(report);
  }

  // Block User
  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    //add this user to blocked list
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUser')
        .doc(userId)
        .set({});
  }

  // Unblock User
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    //unblocked in firebase
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUser')
        .doc(blockedUserId)
        .delete();
  }

  // Get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;

    //get data of blocked user
    final snapshot = await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUser')
        .get();

    //return as a list
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Follow user
  Future<void> followUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    //add target user to the current user following
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .set({});

    //add current user to the target user follower
    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .set({});
  }

  // Unfollow user
  Future<void> unFollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    //remove target user to the current user following
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .delete();

    //remove current user to the target user follower
    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .delete();
  }

  // Get user followers list
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    final snapshot = await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get user following list
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot = await _db
        .collection('Users')
        .doc(uid)
        .collection('Following')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Search User
  Future<List<UserProfile>> searchUserInFirebase(String searchTerm) async {
    try {
      final lowerTerm = searchTerm.toLowerCase();

      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: lowerTerm)
          .where('username', isLessThanOrEqualTo: '$lowerTerm\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
