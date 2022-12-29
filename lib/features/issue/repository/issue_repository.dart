import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sorun_takip_sistemi/core/constants/firebase_constants.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/providers/storage_repository_provider.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/model/issue_model.dart';
import 'package:uuid/uuid.dart';

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageRepositoryProvider),
  );
});

class IssueRepository {
  final FirebaseFirestore _firestore;
  final StorageRepository _storage;

  IssueRepository(
      {required FirebaseFirestore firestore,
      required StorageRepository storage})
      : _firestore = firestore,
        _storage = storage;

  CollectionReference get _issues =>
      _firestore.collection(FirebaseConstants.issuesCollection);

  static const _uuid = Uuid();

  FutureVoid createIssue({
    required String projectId,
    required String assignedTo,
    required String priority,
    required List<String> labels,
    required DateTime due,
    required List<File>? attachments,
    required String title,
    required String description,
  }) async {
    try {
      final issueId = _uuid.v4();
      List<String> attachmentsURL = [];
      if (attachments != null) {
        for (var attachment in attachments) {
          final attachmentName = _uuid.v4();
          final attachmentURL = await _storage.storeFile(
            path: 'projects/$projectId/issues/$issueId/attachments',
            id: attachmentName,
            file: attachment,
            webFile: null,
          );
          attachmentsURL.add(attachmentURL);
        }
      }

      IssueModel issueModel = IssueModel(
        id: issueId,
        projectId: projectId,
        status: 'Yapılacak',
        assignedTo: assignedTo,
        priority: priority,
        labels: labels,
        created: DateTime.now(),
        due: due,
        completed: null,
        attachments: attachmentsURL.isEmpty ? [] : attachmentsURL,
        title: title,
        description: description,
      );

      return right(
        await _issues.doc(issueId).set(
              issueModel.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<IssueModel>> getIssuesByProjectId({required String projectId}) {
    return _issues.where('projectId', isEqualTo: projectId).snapshots().map(
      (event) {
        List<IssueModel> projectIssues = [];
        for (var doc in event.docs) {
          projectIssues.add(
            IssueModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return projectIssues;
      },
    );
  }

  Stream<List<IssueModel>> getIssuesByUserId({required String userId}) {
    return _issues.where('assignedTo', isEqualTo: userId).snapshots().map(
      (event) {
        List<IssueModel> userIssues = [];
        for (var doc in event.docs) {
          userIssues.add(
            IssueModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return userIssues;
      },
    );
  }

  Stream<IssueModel> getIssueById({required String issueId}) {
    return _issues.doc(issueId).snapshots().map(
          (event) => IssueModel.fromMap(
            event.data() as Map<String, dynamic>,
          ),
        );
  }

  FutureVoid updateIssue({
    required String projectId,
    required String issueId,
    required String assignedTo,
    required String priority,
    required String status,
    required List<String> labels,
    required DateTime due,
    required List<File>? attachments,
    required String title,
    required String description,
  }) async {
    try {
      List<String> attachmentsURL = [];
      if (attachments != null) {
        for (var attachment in attachments) {
          final attachmentName = _uuid.v4();
          final attachmentURL = await _storage.storeFile(
            path: 'projects/$projectId/issues/$issueId/attachments',
            id: attachmentName,
            file: attachment,
            webFile: null,
          );
          attachmentsURL.add(attachmentURL);
        }
      }

      return right(
        await _issues.doc(issueId).update(
          {
            'title': title.trim(),
            'description': description.trim(),
            'assignedTo': assignedTo,
            'priority': priority,
            'status': status,
            'labels': labels,
            'due': due,
            'completed': status == "Yapılmış" ? DateTime.now() : null,
            'attachments': FieldValue.arrayUnion(attachmentsURL)
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
