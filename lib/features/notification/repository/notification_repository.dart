import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sorun_takip_sistemi/core/constants/firebase_constants.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';
import 'package:sorun_takip_sistemi/core/providers/firebase_providers.dart';
import 'package:sorun_takip_sistemi/core/type_defs.dart';
import 'package:sorun_takip_sistemi/model/notification_model.dart';
import 'package:uuid/uuid.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    firestore: ref.read(firestoreProvider),
  );
});

class NotificationRepository {
  final FirebaseFirestore _firestore;
  CollectionReference get _notifications => _firestore.collection(
        FirebaseConstants.notificationsCollection,
      );

  NotificationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final uuid = const Uuid();

  FutureVoid createNotification(
      {required bool isInformation,
      required bool isProjectInvitation,
      required bool isTeamInvitation,
      required String receiverId,
      required String receiverName,
      required String senderId,
      required String senderName,
      required String projectTeamName,
      required String projectTeamId,
      required String message}) async {
    try {
      final notificationId = uuid.v4();

      final notification = NotificationModel(
          id: notificationId,
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

      return right(
        await _notifications.doc(notificationId).set(
              notification.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<NotificationModel>> getNotificationsByUser({
    required String uid,
  }) {
    return _notifications.where('receiverId', isEqualTo: uid).snapshots().map(
      (event) {
        List<NotificationModel> notifications = [];
        for (var doc in event.docs) {
          notifications.add(
            NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return notifications;
      },
    );
  }

  Stream<List<NotificationModel>> getInvitationsByUserandProject({
    required String projectTeamId,
    required String uid,
  }) {
    return _notifications
        .where('receiverId', isEqualTo: uid)
        .where('projectTeamId', isEqualTo: projectTeamId)
        .where('isProjectInvitation', isEqualTo: true)
        .snapshots()
        .map(
      (event) {
        List<NotificationModel> notifications = [];
        for (var doc in event.docs) {
          notifications.add(
            NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }
        return notifications;
      },
    );
  }

  FutureVoid deleteNotification({required String notificationId}) async {
    try {
      return right(await _notifications.doc(notificationId).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
