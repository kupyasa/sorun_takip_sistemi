import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sorun_takip_sistemi/core/constants/firebase_constants.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/providers/storage_repository_provider.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/model/comment_model.dart';
import 'package:uuid/uuid.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageRepositoryProvider),
  );
});

class CommentRepository {
  final FirebaseFirestore _firestore;
  final StorageRepository _storage;

  CommentRepository({required firestore, required storage})
      : _firestore = firestore,
        _storage = storage;

  static const Uuid _uuid = Uuid();

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid createComment({
    required String projectTeamId,
    required String? issueId,
    required String senderName,
    required String senderId,
    required String message,
    required List<File>? attachments,
  }) async {
    try {
      final commentId = _uuid.v4();
      List<String> attachmentsURL = [];
      if (attachments != null) {
        if (issueId != null) {
          for (var attachment in attachments) {
            final attachmentName = _uuid.v4();
            final attachmentURL = await _storage.storeFile(
              path:
                  'projects/$projectTeamId/issues/$issueId/comments/$commentId/attachments',
              id: attachmentName,
              file: attachment,
              webFile: null,
            );
            attachmentsURL.add(attachmentURL);
          }
        } else {
          for (var attachment in attachments) {
            final attachmentName = _uuid.v4();
            final attachmentURL = await _storage.storeFile(
              path: 'projects/$projectTeamId/messages/$commentId/attachments',
              id: attachmentName,
              file: attachment,
              webFile: null,
            );
            attachmentsURL.add(attachmentURL);
          }
        }
      }

      final CommentModel commentModel = CommentModel(
          id: commentId,
          projectTeamId: projectTeamId,
          issueId: issueId,
          senderName: senderName,
          senderId: senderId,
          message: message,
          created: DateTime.now(),
          attachments: attachmentsURL);

      return right(
        await _comments.doc(commentId).set(
              commentModel.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteComment({required String id}) async {
    try {
      return right(
        await _comments.doc(id).delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommentModel>> getCommentsByIssueId({required String issueId}) {
    return _comments.where('issueId', isEqualTo: issueId).snapshots().map(
      (event) {
        List<CommentModel> comments = [];
        for (var doc in event.docs) {
          comments
              .add(CommentModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        return comments;
      },
    );
  }
}
