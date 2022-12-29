import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sorun_takip_sistemi/core/constants/firebase_constants.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/providers/storage_repository_provider.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/model/project_model.dart';
import 'package:sorun_takip_sistemi/model/user_model.dart';
import 'package:uuid/uuid.dart';

final projectRepositoryProvider = Provider((ref) {
  return ProjectRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageRepositoryProvider),
  );
});

class ProjectRepository {
  final FirebaseFirestore _firestore;
  final StorageRepository _storage;
  ProjectRepository(
      {required FirebaseFirestore firestore,
      required StorageRepository storage})
      : _firestore = firestore,
        _storage = storage;

  CollectionReference get _projects =>
      _firestore.collection(FirebaseConstants.projectsCollection);

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  static const _uuid = Uuid();

  FutureVoid createProject({
    required String title,
    required String description,
    required List<String> owners,
    required List<String> members,
    File? projectPic,
  }) async {
    try {
      var projectId = _uuid.v4();

      final projectPicURL = await _storage.storeFile(
        path: 'projects/$projectId/',
        id: projectId,
        file: projectPic,
        webFile: null,
      );

      ProjectModel newProject = ProjectModel(
        title: title.trim(),
        description: description.trim(),
        projectPic: projectPicURL,
        owners: owners,
        members: members,
        id: projectId,
      );

      return right(
        await _projects.doc(newProject.id).set(
              newProject.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ProjectModel>> getProjectsOwnedByUser(String userId) {
    return _projects
        .where(
          "owners",
          arrayContains: userId,
        )
        .snapshots()
        .map(
      (event) {
        List<ProjectModel> projectsOwnedByUser = [];
        for (var doc in event.docs) {
          projectsOwnedByUser.add(
            ProjectModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        for (var element in projectsOwnedByUser) {
          print(element.title);
        }
        return projectsOwnedByUser;
      },
    );
  }

  Stream<List<ProjectModel>> getProjectsWhereUserIsMemberOf(String userId) {
    return _projects
        .where(
          "members",
          arrayContains: userId,
        )
        .snapshots()
        .map(
      (event) {
        List<ProjectModel> projectsWhereUserMemberOf = [];
        for (var doc in event.docs) {
          projectsWhereUserMemberOf.add(
            ProjectModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }

        return projectsWhereUserMemberOf;
      },
    );
  }

  Stream<ProjectModel> getProjectById(String projectId) {
    return _projects.doc(projectId).snapshots().map(
          (event) => ProjectModel.fromMap(
            event.data() as Map<String, dynamic>,
          ),
        );
  }

  Future<ProjectModel> getProjectByIdFuture(String projectId) async {
    return await _projects.doc(projectId).get().then(
          (value) => ProjectModel.fromMap(value.data() as Map<String, dynamic>),
        );
  }

  FutureVoid updateProject(
      {required String projectId,
      required String title,
      required String description,
      File? projectPic,
      String? oldProjectPicURL}) async {
    try {
      if (projectPic != null) {
        if (oldProjectPicURL != null) {
          await _storage.deleteFile(url: oldProjectPicURL);
        }

        print("hello there");
        final projectPicURL = await _storage.storeFile(
          path: 'projects/$projectId/',
          id: projectId,
          file: projectPic,
          webFile: null,
        );
        print(projectPicURL);

        return right(
          await _projects.doc(projectId).update(
            {
              'title': title.trim(),
              'description': description.trim(),
              'projectPic': projectPicURL
            },
          ),
        );
      } else {
        return right(
          await _projects.doc(projectId).update(
            {
              'title': title.trim(),
              'description': description.trim(),
            },
          ),
        );
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ProjectModel>> getProjectsByQuery({required String query}) {
    return _projects
        .where(
          "title",
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
        List<ProjectModel> queryResult = [];
        for (var doc in event.docs) {
          queryResult.add(
            ProjectModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }

        return queryResult;
      },
    );
  }

  Stream<List<UserModel>> getProjectMembers(
      {required List<String> memberUids}) {
    return _users
        .where(
          'uid',
          whereIn: memberUids,
        )
        .snapshots()
        .map(
      (event) {
        List<UserModel> projectMembers = [];
        for (var doc in event.docs) {
          projectMembers.add(
            UserModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return projectMembers;
      },
    );
  }

  Future<List<UserModel>> getProjectMembersFuture(
      {required List<String> memberUids}) {
    return _users
        .where(
          'uid',
          whereIn: memberUids,
        )
        .get()
        .then(
      (event) {
        List<UserModel> projectMembers = [];
        for (var doc in event.docs) {
          projectMembers.add(
            UserModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return projectMembers;
      },
    );
  }

  Stream<List<UserModel>> getProjectOwners({
    required List<String> ownerUids,
  }) {
    return _users
        .where(
          'uid',
          whereIn: ownerUids,
        )
        .snapshots()
        .map(
      (event) {
        List<UserModel> projectOwners = [];
        for (var doc in event.docs) {
          projectOwners.add(
            UserModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return projectOwners;
      },
    );
  }

  FutureVoid addMemberToProject(
      {required String projectId, required String memberId}) async {
    try {
      ProjectModel project = await _projects.doc(projectId).get().then(
          (value) =>
              ProjectModel.fromMap(value.data() as Map<String, dynamic>));

      if (!project.members.contains(memberId) &&
          !project.owners.contains(memberId)) {
        return right(
          await _projects.doc(projectId).update(
            {
              'members': FieldValue.arrayUnion([memberId])
            },
          ),
        );
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteMemberFromProject(
      {required String projectId, required String memberId}) async {
    try {
      ProjectModel project = await _projects.doc(projectId).get().then(
          (value) =>
              ProjectModel.fromMap(value.data() as Map<String, dynamic>));

      if (project.members.contains(memberId)) {
        return right(
          await _projects.doc(projectId).update(
            {
              'members': FieldValue.arrayRemove([memberId])
            },
          ),
        );
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
