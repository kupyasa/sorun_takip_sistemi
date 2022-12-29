import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/repository/auth_repository.dart';
import 'package:sorun_takip_sistemi/model/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangeProvider = StreamProvider.autoDispose((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider =
    StreamProvider.autoDispose.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final getUsersByQueryProvider =
    StreamProvider.autoDispose.family((ref, String query) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUsersByQuery(query: query);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signIn(
    BuildContext context, {
    required email,
    required password,
    required name,
    required surname,
    required phone,
    required address,
    required File? profilePicFile,
  }) async {
    state = true;
    final user = await _authRepository.signIn(
      email: email,
      password: password,
      name: name,
      surname: surname,
      phone: phone,
      address: address,
      profilePicFile: profilePicFile,
    );
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  void logIn(BuildContext context, {required email, required password}) async {
    state = true;
    final user = await _authRepository.logIn(
      email: email,
      password: password,
    );
    state = false;
    user.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  Future<void> updateUser(
      {required String uid,
      required String name,
      required String surname,
      required String phone,
      required String address,
      File? profilePic,
      String? oldProfilePicURL,
      required BuildContext context}) async {
    state = true;

    final res = await _authRepository.updateUser(
      uid: uid,
      name: name,
      surname: surname,
      phone: phone,
      address: address,
      profilePic: profilePic,
      oldProfilePicURL: oldProfilePicURL,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Kullanıcı başarıyla güncellendi!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<UserModel>> getUsersByQuery({required String query}) {
    return _authRepository.getUsersByQuery(query: query);
  }

  Future<void> sendPasswordResetLink(
      {required String email, required BuildContext context}) async {
    state = true;
    final res = await _authRepository.sendPasswordResetLink(email: email);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Şifre yenileme e-postası gönderildi.");
        Routemaster.of(context).push('/');
      },
    );
  }

  Future<void> logout({required BuildContext context}) async {
    state = true;
    final res = await _authRepository.logOut();
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).push('/'),
    );
  }
}
