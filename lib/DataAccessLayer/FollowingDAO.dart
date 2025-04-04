import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Following.dart';

class FollowingDAO {
  static Future<void> addFollowing(Following following) async {
    try {
      await FirebaseFirestore.instance.collection('followings').doc().set({
        'followerUID': following.followerUID,
        'followingUID': following.followingUID,
      });
    } catch (e) {
      //print('Error storing registration: $e');
    }
  }

  static Future<void> removeFollowing(String followerUID, String followingUID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('followings')
          .where('followerUID', isEqualTo: followerUID)
          .where('followingUID', isEqualTo: followingUID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      } else {
        //print('No matching document found for deletion');
      }
    } catch (e) {
      //print('Error removing registration: $e');
    }
  }

  static Future<int> getNumberFollowing(String followerUID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('followings').where('followerUID', isEqualTo: followerUID).get();

      return querySnapshot.size;
    } catch (e) {
      //print('Error fetching number of followings: $e');
      return 0;
    }
  }

  static Future<List<String>> getAllFollowingsForUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('followings').where('followerUID', isEqualTo: userId).get();

      return querySnapshot.docs.map((doc) => Following.fromSnapshot(doc).followingUID).toList();
    } catch (e) {
      //print('Error fetching followings: $e');
      return [];
    }
  }

  static Future<bool> isUserFollowedByUser(String followerUserId, String followingUserId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('followings')
          .where('followerUserId', isEqualTo: followerUserId)
          .where('followingUserId', isEqualTo: followingUserId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      //print('Error checking if followed: $e');
      return false;
    }
  }
}
