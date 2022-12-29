import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/issue/repository/issue_repository.dart';
import 'package:sorun_takip_sistemi/model/issue_model.dart';

final getIssuesByProjectProvider = StreamProvider.autoDispose
    .family<List<IssueModel>, String>((ref, projectId) {
  return ref
      .watch(issueControllerProvider.notifier)
      .getIssuesByProjectId(projectId: projectId);
});

final getIssuesByUserProvider =
    StreamProvider.autoDispose.family<List<IssueModel>, String>((ref, userId) {
  return ref
      .watch(issueControllerProvider.notifier)
      .getIssuesByUserId(userId: userId);
});

final getIssueByIdProvider = StreamProvider.autoDispose
    .family<IssueModel, String>((ref, String issueId) {
  return ref
      .watch(issueControllerProvider.notifier)
      .getIssueById(issueId: issueId);
});

final issueControllerProvider =
    StateNotifierProvider<IssueController, bool>((ref) {
  return IssueController(
    issueRepository: ref.watch(issueRepositoryProvider),
  );
});

class IssueController extends StateNotifier<bool> {
  final IssueRepository _issueRepository;
  IssueController({required IssueRepository issueRepository})
      : _issueRepository = issueRepository,
        super(false);

  Future<void> createIssue(
      {required String projectId,
      required String assignedTo,
      required String priority,
      required List<String> labels,
      required DateTime due,
      required List<File>? attachments,
      required String title,
      required String description,
      required BuildContext context}) async {
    state = true;
    final res = await _issueRepository.createIssue(
        projectId: projectId,
        assignedTo: assignedTo,
        priority: priority,
        labels: labels,
        due: due,
        attachments: attachments,
        title: title,
        description: description);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Sorun başarıyla oluşturuldu!');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<IssueModel>> getIssuesByProjectId({required String projectId}) {
    return _issueRepository.getIssuesByProjectId(
      projectId: projectId,
    );
  }

  Stream<List<IssueModel>> getIssuesByUserId({required String userId}) {
    return _issueRepository.getIssuesByUserId(
      userId: userId,
    );
  }

  Stream<IssueModel> getIssueById({required String issueId}) {
    return _issueRepository.getIssueById(issueId: issueId);
  }

  Future<void> updateIssue(
      {required String projectId,
      required String issueId,
      required String assignedTo,
      required String priority,
      required String status,
      required List<String> labels,
      required DateTime due,
      required List<File>? attachments,
      required String title,
      required String description,
      required BuildContext context}) async {
    state = true;
    final res = await _issueRepository.updateIssue(
        projectId: projectId,
        issueId: issueId,
        assignedTo: assignedTo,
        priority: priority,
        labels: labels,
        status: status,
        due: due,
        attachments: attachments,
        title: title,
        description: description);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Sorun başarıyla güncellendi!');
        Routemaster.of(context).pop();
      },
    );
  }
}
