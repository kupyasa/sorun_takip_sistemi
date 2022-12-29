import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/project/repository/project_repository.dart';
import 'package:sorun_takip_sistemi/model/project_model.dart';
import 'package:sorun_takip_sistemi/model/user_model.dart';

final getProjectsOwnedByUserProvider = StreamProvider.autoDispose
    .family<List<ProjectModel>, String>((ref, userId) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectsOwnedByUser(userId);
});

final getProjectsWhereUserIsMemberOfProvider = StreamProvider.autoDispose
    .family<List<ProjectModel>, String>((ref, userId) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectsWhereUserIsMemberOf(userId);
});

final getProjectByIdProvider =
    StreamProvider.autoDispose.family<ProjectModel, String>((ref, projectId) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectById(projectId);
});

final getProjectsByQueryProvider =
    StreamProvider.autoDispose.family<List<ProjectModel>, String>((ref, query) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectsByQuery(query: query);
});

final getProjectMembersProvider = StreamProvider.autoDispose
    .family<List<UserModel>, List<String>>((ref, memberUids) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectMembers(memberUids: memberUids);
});

final getProjectOwnersProvider = StreamProvider.autoDispose
    .family<List<UserModel>, List<String>>((ref, ownerUids) {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectOwners(ownerUids: ownerUids);
});

final getProjectByIdFutureProvider =
    FutureProvider.family<ProjectModel, String>((ref, projectId) async {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectByIdFuture(projectId);
});

final getProjectMembersFutureProvider =
    FutureProvider.family<List<UserModel>, List<String>>(
        (ref, memberUids) async {
  var projectController = ref.watch(projectControllerProvider.notifier);
  return projectController.getProjectMembersFuture(memberUids: memberUids);
});

final projectControllerProvider =
    StateNotifierProvider<ProjectController, bool>((ref) {
  return ProjectController(
    projectRepository: ref.watch(projectRepositoryProvider),
    ref: ref,
  );
});

class ProjectController extends StateNotifier<bool> {
  final ProjectRepository _projectRepository;
  final Ref _ref;

  ProjectController(
      {required ProjectRepository projectRepository, required Ref ref})
      : _projectRepository = projectRepository,
        _ref = ref,
        super(false);

  Future<void> createProject(
      {required String title,
      required String description,
      File? projectPic,
      required BuildContext context}) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    final res = await _projectRepository.createProject(
      title: title,
      description: description,
      owners: [uid],
      members: [],
      projectPic: projectPic,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Proje başarıyla oluşturuldu!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<ProjectModel>> getProjectsOwnedByUser(String userId) {
    return _projectRepository.getProjectsOwnedByUser(userId);
  }

  Stream<List<ProjectModel>> getProjectsWhereUserIsMemberOf(String userId) {
    return _projectRepository.getProjectsWhereUserIsMemberOf(userId);
  }

  Stream<ProjectModel> getProjectById(String projectId) {
    return _projectRepository.getProjectById(projectId);
  }

  Future<ProjectModel> getProjectByIdFuture(String projectId) async {
    return await _projectRepository.getProjectByIdFuture(projectId);
  }

  Future<void> updateProject(
      {required String projectId,
      required String title,
      required String description,
      File? projectPic,
      String? oldProjectPicURL,
      required BuildContext context}) async {
    state = true;

    final res = await _projectRepository.updateProject(
        projectId: projectId,
        title: title,
        description: description,
        projectPic: projectPic,
        oldProjectPicURL: oldProjectPicURL);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Proje başarıyla düzenlendi!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<ProjectModel>> getProjectsByQuery({required String query}) {
    return _projectRepository.getProjectsByQuery(
      query: query,
    );
  }

  Stream<List<UserModel>> getProjectMembers({
    required List<String> memberUids,
  }) {
    return _projectRepository.getProjectMembers(
      memberUids: memberUids,
    );
  }

  Future<List<UserModel>> getProjectMembersFuture({
    required List<String> memberUids,
  }) {
    return _projectRepository.getProjectMembersFuture(
      memberUids: memberUids,
    );
  }

  Stream<List<UserModel>> getProjectOwners({
    required List<String> ownerUids,
  }) {
    return _projectRepository.getProjectOwners(
      ownerUids: ownerUids,
    );
  }

  Future<void> addMemberToProject(
      {required String projectId,
      required String memberId,
      required BuildContext context}) async {
    state = true;

    final res = await _projectRepository.addMemberToProject(
      projectId: projectId,
      memberId: memberId,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Üye projeye eklendi!');
      },
    );
  }

  Future<void> deleteMemberFromProject(
      {required String projectId,
      required String memberId,
      required BuildContext context}) async {
    state = true;

    final res = await _projectRepository.deleteMemberFromProject(
      projectId: projectId,
      memberId: memberId,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Üye projeden çıkarıldı!');
      },
    );
  }
}
