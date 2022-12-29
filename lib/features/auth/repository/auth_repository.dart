import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sorun_takip_sistemi/core/constants/constants.dart';
import 'package:sorun_takip_sistemi/core/constants/firebase_constants.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/providers/storage_repository_provider.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/model/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  final storageRepository = ref.watch(storageRepositoryProvider);
  return AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider),
      storageRepository: storageRepository);
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final StorageRepository _storageRepository;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn,
      required StorageRepository storageRepository})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _storageRepository = storageRepository;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signIn({
    required email,
    required password,
    required name,
    required surname,
    required phone,
    required address,
    required File? profilePicFile,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var profilePicURL = Constants.avatarDefault;
      if (profilePicFile != null) {
        profilePicURL = await _storageRepository.storeFile(
          path: 'profilePic/${credential.user!.uid!}',
          id: credential.user!.uid!,
          file: profilePicFile,
          webFile: null,
        );
      }

      UserModel userModel = UserModel(
        name: name,
        surname: surname,
        phone: phone,
        profilePic: profilePicURL,
        address: address,
        uid: credential.user!.uid,
      );

      await _users.doc(credential.user!.uid).set(
            userModel.toMap(),
          );

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> logIn({
    required email,
    required password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = await getUserData(credential.user!.uid).first;

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid updateUser(
      {required String uid,
      required String name,
      required String surname,
      required String phone,
      required String address,
      File? profilePic,
      String? oldProfilePicURL}) async {
    try {
      if (profilePic != null) {
        if (oldProfilePicURL != null) {
          await _storageRepository.deleteFile(url: oldProfilePicURL);
        }

        final profilePicURL = await _storageRepository.storeFile(
          path: 'users/$uid/',
          id: uid,
          file: profilePic,
          webFile: null,
        );

        return right(
          await _users.doc(uid).update(
            {
              'name': name.trim(),
              'surname': surname.trim(),
              'phone': phone.trim(),
              'address': address.trim(),
              'profilePic': profilePicURL
            },
          ),
        );
      } else {
        return right(
          await _users.doc(uid).update(
            {
              'name': name.trim(),
              'surname': surname.trim(),
              'phone': phone.trim(),
              'address': address.trim(),
            },
          ),
        );
      }
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<UserModel>> getUsersByQuery({required String query}) {
    return _users
        .where(
          "name",
          isGreaterThanOrEqualTo: query.trim().isEmpty ? 0 : query.trim(),
          isLessThan: query.trim().isEmpty
              ? null
              : query.trim().substring(0, query.trim().length - 1) +
                  String.fromCharCode(
                    query.trim().codeUnitAt(query.trim().length - 1) + 1,
                  ),
        )
        .snapshots()
        .map(
      (event) {
        List<UserModel> queryResult = [];
        for (var doc in event.docs) {
          queryResult.add(
            UserModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }

        return queryResult;
      },
    );
  }

  FutureEither<void> sendPasswordResetLink({required String email}) async {
    try {
      return right(
        await _auth.sendPasswordResetEmail(email: email),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<void> logOut() async {
    try {
      return right(await _auth.signOut());
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
