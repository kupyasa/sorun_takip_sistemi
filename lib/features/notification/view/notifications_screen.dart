import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/notification/controller/notification_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void acceptProjectInvitation({
    required projectId,
    required userId,
    required notificationId,
    required BuildContext context,
  }) {
    ref.watch(projectControllerProvider.notifier).addMemberToProject(
          projectId: projectId,
          memberId: userId,
          context: context,
        );

    ref.watch(notificationControllerProvider.notifier).deleteNotification(
          notificationId: notificationId,
          context: context,
        );
  }

  void acceptTeamInvitation({
    required projectId,
    required userId,
    required notificationId,
    required BuildContext context,
  }) {}

  void rejectInvitationOrDeleteNotification({
    required notificationId,
    required BuildContext context,
  }) {
    ref.watch(notificationControllerProvider.notifier).deleteNotification(
          notificationId: notificationId,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bildirimlerim'),
          centerTitle: false,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => displayDrawer(context),
              );
            },
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                  onPressed: () => displayEndDrawer(context),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            ref.watch(getNotificationsByUserProvider(user.uid)).when(
                  data: (notifications) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final notification = notifications[index];
                          return ListTile(
                              title: Text(notification.message),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (notification.isProjectInvitation ||
                                      notification.isTeamInvitation) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Icon(Icons.check),
                                        onPressed: () {
                                          if (notification
                                              .isProjectInvitation) {
                                            acceptProjectInvitation(
                                              projectId:
                                                  notification.projectTeamId,
                                              userId: notification.receiverId,
                                              notificationId: notification.id,
                                              context: context,
                                            );
                                          } else if (notification
                                              .isTeamInvitation) {
                                            acceptTeamInvitation(
                                              projectId:
                                                  notification.projectTeamId,
                                              userId: notification.receiverId,
                                              notificationId: notification.id,
                                              context: context,
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Icon(Icons.close),
                                    onPressed: () {
                                      rejectInvitationOrDeleteNotification(
                                        notificationId: notification.id,
                                        context: context,
                                      );
                                    },
                                  ),
                                ],
                              ) /*(notification.isProjectInvitation ||
                                    notification.isTeamInvitation)
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Kabul Et'),
                                    onPressed: () {
                                      if (notification.isProjectInvitation) {
                                        acceptProjectInvitation(
                                          projectId: notification.projectTeamId,
                                          userId: notification.receiverId,
                                          notificationId: notification.id,
                                          context: context,
                                        );
                                      } else if (notification
                                          .isTeamInvitation) {
                                        acceptTeamInvitation(
                                          projectId: notification.projectTeamId,
                                          userId: notification.receiverId,
                                          notificationId: notification.id,
                                          context: context,
                                        );
                                      }
                                    },
                                  )
                                : null,*/
                              );
                        },
                        shrinkWrap: true,
                      ),
                    );
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                ),
          ],
        ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );
  }
}
