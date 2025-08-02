import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/const/firebase_collection_const.dart';

import 'package:whatsapp_clone/features/user/data/data_sources/remote/user_remote_data_source.dart';
import 'package:whatsapp_clone/features/user/data/models/user_model.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;

  UserRemoteDataSourceImpl({
    required this.fireStore,
    required this.auth,
  });

  String _verificationId = "";

  @override
  Future<void> createUser(UserEntity user) async {
    debugPrint("🔧 Creating user document");
    final userCollection = fireStore.collection(FirebaseCollectionConst.users);

    final uid = await getCurrentUID();
    debugPrint("🔧 Current UID: $uid");

    final newUser = UserModel(
      email: user.email,
      uid: uid,
      isOnline: user.isOnline,
      phoneNumber: user.phoneNumber,
      username: user.username,
      profileUrl: user.profileUrl,
      status: user.status,
    ).toDocument();

    try {
      // Use await instead of .then() for better error handling
      final userDoc = await userCollection.doc(uid).get();
      
      if (!userDoc.exists) {
        debugPrint("🔧 Creating new user document");
        await userCollection.doc(uid).set(newUser);
        debugPrint("✅ User document created successfully");
      } else {
        debugPrint("🔧 Updating existing user document");
        await userCollection.doc(uid).update(newUser);
        debugPrint("✅ User document updated successfully");
      }
    } catch (e) {
      debugPrint("❌ Error creating user: $e");
      throw Exception("Error occur while creating user: $e");
    }
  }

  @override
  Stream<List<UserEntity>> getAllUsers() {
    debugPrint("🔍 Getting all users");
    debugPrint("🔐 Current user authenticated: ${auth.currentUser != null}");

    final userCollection = fireStore.collection(FirebaseCollectionConst.users);
    return userCollection.snapshots().handleError((error) {
      debugPrint("❌ Firestore error in getAllUsers: $error");
      if (error.toString().contains('PERMISSION_DENIED')) {
        debugPrint(
            "❌ Permission denied - check Firestore security rules for collection access");
      }
    }).map((querySnapshot) {
      debugPrint("📄 Got ${querySnapshot.docs.length} users from Firestore");
      return querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    });
  }

  @override
  Future<String> getCurrentUID() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in");
    }
    debugPrint("🔍 Current authenticated user UID: ${currentUser.uid}");
    return currentUser.uid;
  }

  @override
  Future<List<ContactEntity>> getDeviceNumber() async {
    debugPrint("📱 Requesting contact permission...");
    List<ContactEntity> contactsList = [];

    try {
      // Check if permission is already granted
      if (await FlutterContacts.requestPermission()) {
        debugPrint("✅ Contact permission granted");
        
        // Optimize: Only fetch necessary properties to speed up loading
        debugPrint("📱 Fetching contacts from device...");
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false, // Disable photos initially for faster loading
        );

        debugPrint("📱 Processing ${contacts.length} contacts...");
        
        for (var contact in contacts) {
          // Only add contacts that have phone numbers
          if (contact.phones.isNotEmpty) {
            contactsList.add(
              ContactEntity(
                name: contact.name,
                photo: null, // Load photos on demand later
                phones: contact.phones,
              ),
            );
          }
        }
        
        debugPrint("✅ Processed ${contactsList.length} contacts with phone numbers");
      } else {
        debugPrint("❌ Contact permission denied");
      }
    } catch (e) {
      debugPrint("❌ Error fetching contacts: $e");
      throw Exception("Failed to fetch device contacts: $e");
    }

    return contactsList;
  }

  @override
  Stream<List<UserEntity>> getSingleUser(String uid) {
    if (uid.isEmpty) {
      debugPrint("ERROR: getSingleUser was called with an empty UID.");
      return const Stream.empty();
    }

    // First way to do it below
    // This method is less efficient and can lead to security issues if not handled properly.
    // final userCollection = fireStore
    //     .collection(FirebaseCollectionConst.users)
    //     .where("uid", isEqualTo: uid);
    // return userCollection.snapshots().map((querySnapshot) =>
    //     querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());

    //Another way to do it below

    debugPrint("🔍 Getting single user with UID: $uid");
    debugPrint("🔐 Current user authenticated: ${auth.currentUser != null}");

    // Use direct document access instead of where query for better performance and security
    final userDoc =
        fireStore.collection(FirebaseCollectionConst.users).doc(uid);

    return userDoc.snapshots().handleError((error) {
      debugPrint("❌ Firestore error in getSingleUser: $error");
      if (error.toString().contains('PERMISSION_DENIED')) {
        debugPrint("❌ Permission denied - check Firestore security rules");
        debugPrint("❌ Make sure user is authenticated and rules allow access");
      }
    }).map((docSnapshot) {
      debugPrint(
          "📄 Document snapshot received - exists: ${docSnapshot.exists}");
      if (docSnapshot.exists) {
        debugPrint("✅ User document found");
        return [UserModel.fromSnapshot(docSnapshot)];
      } else {
        debugPrint("⚠️ User document does not exist for UID: $uid");
        return [];
      }
    });
  }

  @override
  Future<bool> isSignIn() async => auth.currentUser?.uid != null;

  @override
  Future<void> signInWithPhoneNumber(String smsPinCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsPinCode,
      );

      await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        toast("Invalid Verification Code");
      } else if (e.code == 'quota-exceeded') {
        toast("SMS quota-exceeded");
      }
    } catch (e) {
      toast("Unknown exception please try again");
    }
  }

  @override
  Future<void> signOut() async => auth.signOut();

  @override
  Future<void> updateUser(UserEntity user) async {
    final userCollection = fireStore.collection(FirebaseCollectionConst.users);

    Map<String, dynamic> userInfo = {};

    if (user.username != "" && user.username != null)
      userInfo['username'] = user.username;
    if (user.status != "" && user.status != null)
      userInfo['status'] = user.status;

    if (user.profileUrl != "" && user.profileUrl != null)
      userInfo['profileUrl'] = user.profileUrl;

    if (user.isOnline != null) userInfo['isOnline'] = user.isOnline;

    userCollection.doc(user.uid).update(userInfo);
  }

  @override
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    phoneVerificationCompleted(AuthCredential authCredential) {
      debugPrint(
          "phone verified: Toekn ${authCredential.token} ${authCredential.signInMethod}");
    }

    phoneVerificationFailed(FirebaseAuthException firebaseAuthException) {
      debugPrint(
        "phone failed : ${firebaseAuthException.message},${firebaseAuthException.code}",
      );
    }

    phoneCodeAutoRetrievalTimeout(String verificationId) {
      _verificationId = verificationId;
      debugPrint("time out :$verificationId");
    }

    phoneCodeSent(String verificationId, int? forceResendingToken) {
      _verificationId = verificationId;
    }

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted,
      verificationFailed: phoneVerificationFailed,
      timeout: const Duration(seconds: 60),
      codeSent: phoneCodeSent,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
    );
  }
}
