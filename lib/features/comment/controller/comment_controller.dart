import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/comment/repository/comment_repository.dart';
import 'package:sorun_takip_sistemi/model/comment_model.dart';

final getCommentsByIssueProvider = StreamProvider.autoDispose
    .family<List<CommentModel>, String>((ref, issueId) {
  return ref
      .watch(commentControllerProvider.notifier)
      .getCommentsByIssue(issueId: issueId);
});

final commentControllerProvider =
    StateNotifierProvider<CommentController, bool>((ref) {
  return CommentController(
    commentRepository: ref.watch(commentRepositoryProvider),
  );
});

class CommentController extends StateNotifier<bool> {
  final CommentRepository _commentRepository;
  CommentController({required CommentRepository commentRepository})
      : _commentRepository = commentRepository,
        super(false);

  Future<void> createComment(
      {required String projectTeamId,
      required String? issueId,
      required String senderName,
      required String senderId,
      required String message,
      required List<File>? attachments,
      required BuildContext context}) async {
    state = true;
    final res = await _commentRepository.createComment(
        projectTeamId: projectTeamId,
        issueId: issueId,
        senderName: senderName,
        senderId: senderId,
        message: message,
        attachments: attachments);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Yorum başarıyla oluşturuldu!');
      },
    );
  }

  Future<void> deleteComment(
      {required String id, required BuildContext context}) async {
    state = true;
    final res = await _commentRepository.deleteComment(id: id);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Yorum başarıyla silindi!');
      },
    );
  }

  Stream<List<CommentModel>> getCommentsByIssue({required String issueId}) {
    return _commentRepository.getCommentsByIssueId(issueId: issueId);
  }
}
