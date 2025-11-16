/*
Database Provider
This provider separates Firestore data handling from UI logic.

  - DatabaseService handles Firebase read/write operations
  - DatabaseProvider exposes that data to the UI

*/

import 'package:flutter/material.dart';
import 'package:twithub/models/comment.dart';
import 'package:twithub/models/post.dart';
import 'package:twithub/models/user.dart';
import 'package:twithub/services/database/database_service.dart';

import '../services/auth/auth_services.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();

  // 1. User Profile

  // get user profile by uid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  // 2. User Post

  //local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  //get posts
  List<Post> get allPosts => _allPosts;

  List<Post> get followingPosts => _followingPosts;

  //post message
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);

    // Instead of reloading all posts, just fetch the new one
    await loadAllPosts();
  }

  //fetch all posts
  Future<void> loadAllPosts() async {
    //get all post from firebase
    final allPosts = await _db.getAllPostsFromFirebase();

    //get blocked user
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //filter out blocked user posts & update local data
    _allPosts = allPosts
        .where((post) => !blockedUserIds.contains(post.uid))
        .toList();

    //filter out the following posts
    loadFollowingPosts();

    //initialize local data
    initializeLikeMap();

    //update UI
    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPost(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //load following post
  Future<void> loadFollowingPosts() async {
    //get current uid
    final currentUid = _auth.getCurrentUid();
    if (currentUid == null) return;

    // Ensure posts are loaded first
    if (_allPosts.isEmpty) {
      await loadAllPosts();
    }

    //get list of uids that the current logged in user follows(from firebase)
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);
    print("Following UIDs: $followingUserIds");

    //filter all post to be the ones for the following tab
    _followingPosts = _allPosts
        .where((post) => followingUserIds.contains(post.uid))
        .toList();

    print("Following posts count: ${_followingPosts.length}");

    //update UI
    notifyListeners();
  }

  //delete Post
  Future<void> deletePost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPosts();
  }

  // 3. User Like

  //like count for each post
  Map<String, int> _likeCounts = {};

  //local list to track post like by current user
  List<String> _likedPosts = [];

  //does current user like this post
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  //get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  //initialize like map locally
  void initializeLikeMap() {
    final currentUserId = _auth.getCurrentUid();

    //clear liked post for when new user signs in clear local data
    _likedPosts.clear();

    //for each post get like data
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      //if the current user already like this post
      if (post.likedBy.contains(currentUserId)) {
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postId) async {
    //store original values in case it fails
    final likePostsOriginal = _likedPosts;
    final likeCountOriginal = _likeCounts;
    //perform like / unlike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }
    //update UI
    notifyListeners();

    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likePostsOriginal;
      _likeCounts = likeCountOriginal;
      notifyListeners();
    }
  }

  // 4. User Comment

  //local list of comment
  final Map<String, List<Comment>> _comments = {};

  //get comment locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  //fetch comment from database for a post
  Future<void> loadComments(String postId) async {
    //get all comment for this post
    final allComments = await _db.getCommentFromFirebase(postId);

    //update local data
    _comments[postId] = allComments;

    //update UI
    notifyListeners();
  }

  //add a comment
  Future<void> addComment(String postId, message) async {
    //add comment in firebase
    await _db.addCommentInFirebase(postId, message);

    // reload comments
    await loadComments(postId);
  }

  //delete a comment
  Future<void> deleteComment(String commentId, postId) async {
    //delete comment in firebase
    await _db.deleteCommentInFirebase(commentId);

    // reload comments
    await loadComments(postId);
  }

  // 5. Account Stuff

  //local list of blocked users
  List<UserProfile> _blockedUser = [];

  //get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUser;

  //fetch blocked users
  Future<void> loadBlockedUser() async {
    //get list of blocked user uid
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //get full user details using uid
    final blockedUsersData = await Future.wait(
      blockedUserIds.map((id) => _db.getUserFromFirebase(id)),
    );

    //return as a list
    _blockedUser = blockedUsersData.whereType<UserProfile>().toList();

    //update UI
    notifyListeners();
  }

  //block user
  Future<void> blockUser(String userId) async {
    //perform block in firebase
    await _db.blockUserInFirebase(userId);

    //reload block user
    await loadBlockedUser();

    //reload data
    await loadAllPosts();

    //update UI
    notifyListeners();
  }

  //unblock user
  Future<void> unblockUser(String blockedUserId) async {
    //perform unblock in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    //reload block user
    await loadBlockedUser();

    //reload data
    await loadAllPosts();

    //update UI
    notifyListeners();
  }

  //report user & post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  // 6. User Follow

  //local map
  final Map<String, List<String>> _follower = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  //get counts for followers & following locally
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;

  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  //load followers
  Future<void> loadUserFollowers(String uid) async {
    //get the list follower uid from firebase
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    //update local data
    _follower[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    //update UI
    notifyListeners();
  }

  //load following
  Future<void> loadUserFollowing(String uid) async {
    //get the list following uid from firebase
    final listOfFollowerUids = await _db.getFollowingUidsFromFirebase(uid);

    //update local data
    _following[uid] = listOfFollowerUids;
    _followingCount[uid] = listOfFollowerUids.length;

    //update UI
    notifyListeners();
  }

  //follow user
  Future<void> followUser(String targetUserId) async {
    //get current uid
    final currentUserId = _auth.getCurrentUid();

    //initialize with empty lists if null
    _following.putIfAbsent(currentUserId!, () => []);
    _follower.putIfAbsent(targetUserId, () => []);

    //follow if current user is not one of the target user followers
    if (!_follower[targetUserId]!.contains(currentUserId)) {
      //add current user to target user follower list
      _follower[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //then add target user to current user following
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }

    //update UI
    notifyListeners();

    try {
      //follow user in firebase
      await _db.followUserInFirebase(targetUserId);

      //reload current user's followers
      await loadUserFollowers(currentUserId);

      //reload current user's following
      await loadUserFollowing(currentUserId);
    } catch (e) {
      //remove current user from target user follower
      _follower[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      //remove current user from target user following
      _following[currentUserId]?.remove(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      //update UI
      notifyListeners();
    }
  }

  //unfollow user
  Future<void> unFollowUser(String targetUserId) async {
    //get current uid
    final currentUserId = _auth.getCurrentUid();

    //initialize lists if they don't exit
    _following.putIfAbsent(currentUserId!, () => []);
    _follower.putIfAbsent(targetUserId, () => []);

    //follow if current user is not one of the target user following
    if (_follower[targetUserId]!.contains(currentUserId)) {
      //remove current user from target user following
      _follower[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      //remove target user from current user following list
      _following[currentUserId]?.remove(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }

    //update UI
    notifyListeners();

    try {
      //unfollow target user in firebase
      await _db.unFollowUserInFirebase(targetUserId);

      //reload user followers
      await loadUserFollowers(currentUserId);

      //reload user following
      await loadUserFollowing(currentUserId);
    } catch (e) {
      //add current user back into target user followers
      _follower[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //add target user back itp current user following list
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      //update UI
      notifyListeners();
    }
  }

  //is current user following target user
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _follower[uid]?.contains(currentUserId) ?? false;
  }

  // 7. Map of Profile

  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  //get list of follower profile for a given user
  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  //get list of following profile for a given user
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  //load follower profile for a given uid
  Future<void> loadUserFollowersProfile(String uid) async {
    try {
      //get list of user profile
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      //create list of user profile
      List<UserProfile> followerProfiles = [];

      //go each follower id
      for (String followerId in followerIds) {
        //get user profile from firebase with uid
        UserProfile? followerProfile = await _db.getUserFromFirebase(
          followerId,
        );

        //add to follower profile
        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }

      //update local data
      _followersProfile[uid] = followerProfiles;

      //update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  //load following profile for a given uid
  Future<void> loadUserFollowingProfile(String uid) async {
    try {
      //get list of user profile
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      //create list of user profile
      List<UserProfile> followingProfiles = [];

      //go each following id
      for (String followingId in followingIds) {
        //get user profile from firebase with uid
        UserProfile? followingProfile = await _db.getUserFromFirebase(
          followingId,
        );

        //add to follower profile
        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }

      //update local data
      _followingProfile[uid] = followingProfiles;

      //update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // 8. Search User

  //list of search results
  List<UserProfile> _searchResult = [];

  //get list of search results
  List<UserProfile> get searchResult => _searchResult;

  //search for a user
  Future<void> searchUser(String searchTerm) async {
    try {
      //search user in firebase
      final result = await _db.searchUserInFirebase(searchTerm);

      //update local data
      _searchResult = result;

      //update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
