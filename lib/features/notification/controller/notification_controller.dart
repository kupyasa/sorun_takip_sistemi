import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/notification/repository/notification_repository.dart';
import 'package:sorun_takip_sistemi/model/notification_model.dart';

final getInvitationsByUserandProjectProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, Map<String, String>>((ref, Map map) {
  return ref
      .watch(notificationControllerProvider.notifier)
      .getInvitationsByUserandProject(
          projectTeamId: map["projectTeamId"]!, uid: map["uid"]!);
});

final getNotificationsByUserProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, String>((ref, String uid) {
  return ref
      .watch(notificationControllerProvider.notifier)
      .getNotificationsByUser(uid: uid);
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationController(
    notificationRepository: notificationRepository,
    ref: ref,
  );
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository;
  final Ref _ref;
  NotificationController(
      {required NotificationRepository notificationRepository,
      required Ref ref})
      : _notificationRepository = notificationRepository,
        _ref = ref,
        super(false);

  Future<void> createNotification(
      {required bool isInformation,
      required bool isProjectInvitation,
      required bool isTeamInvitation,
      required String receiverId,
      required String receiverName,
      required String senderId,
      required String senderName,
      required String projectTeamName,
      required String projectTeamId,
      required String message,
      required BuildContext context}) async {
    state = true;
    final res = await _notificationRepository.createNotification(
        isInformation: isInformation,
        isProjectInvitation: isProjectInvitation,
        isTeamInvitation: isTeamInvitation,
        receiverId: receiverId,
        receiverName: receiverName,
        senderId: senderId,
        senderName: senderName,
        projectTeamName: projectTeamName,
        projectTeamId: projectTeamId,
        message: message);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Bildiri başarıyla gönderildi.");
    });
  }

  Stream<List<NotificationModel>> getNotificationsByUser(
      {required String uid}) {
    return _notificationRepository.getNotificationsByUser(
      uid: uid,
    );
  }

  Stream<List<NotificationModel>> getInvitationsByUserandProject({
    required String projectTeamId,
    required String uid,
  }) {
    return _notificationRepository.getInvitationsByUserandProject(
        projectTeamId: projectTeamId, uid: uid);
  }

  Future<void> deleteNotification(
      {required String notificationId, required BuildContext context}) async {
    state = true;
    final res = await _notificationRepository.deleteNotification(
      notificationId: notificationId,
    );
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Bildiri silindi.");
    });
  }
}
