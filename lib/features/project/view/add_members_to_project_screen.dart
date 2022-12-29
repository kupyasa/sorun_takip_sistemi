import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/notification/controller/notification_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class AddMembersToProjectScreen extends ConsumerStatefulWidget {
  final String projectId;
  const AddMembersToProjectScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AddMembersToProjectScreenState();
}

class _AddMembersToProjectScreenState
    extends ConsumerState<AddMembersToProjectScreen> {
  String query = '';
  final queryController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    queryController.dispose();
    super.dispose();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void sendProjectInvite(
      {required bool isInformation,
      required bool isProjectInvitation,
      required bool isTeamInvitation,
      required String receiverId,
      required String receiverName,
      required String senderId,
      required String senderName,
      required String projectTeamName,
      required String projectTeamId,
      required BuildContext context}) {
    final String message =
        "$senderName tarafından $projectTeamName projesine davet edildiniz.";

    ref.watch(notificationControllerProvider.notifier).createNotification(
          isInformation: isInformation,
          isProjectInvitation: isProjectInvitation,
          isTeamInvitation: isTeamInvitation,
          receiverId: receiverId,
          receiverName: receiverName,
          senderId: senderId,
          senderName: senderName,
          projectTeamName: projectTeamName,
          projectTeamId: projectTeamId,
          message: message,
          context: context,
        );
  }

  void navigateToUserProfile(
      {required String uid, required BuildContext context}) {
    Routemaster.of(context).push('/users/$uid');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Üye Ekle'),
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
        body: ref.watch(getProjectByIdProvider(widget.projectId)).when(
              data: (projectInfo) {
                return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText:
                                "Bulmak istediğiniz kullanıcının adını giriniz.",
                            labelText: "Kullanıcı Adı",
                          ),
                          controller: queryController,
                          onChanged: (val) {
                            setState(() {
                              query = val;
                            });
                            print(query);
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ref.watch(getUsersByQueryProvider(query)).when(
                              data: (users) {
                                return ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (BuildContext listViewContext,
                                      int index) {
                                    final searchedUser = users[index];
                                    return (!((projectInfo.owners
                                                .contains(searchedUser.uid)) ||
                                            (projectInfo.members
                                                .contains(searchedUser.uid))))
                                        ? ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  searchedUser.profilePic),
                                              radius: 20,
                                            ),
                                            title: Text(
                                                "${searchedUser.name} ${searchedUser.surname}"),
                                            onTap: () {
                                              navigateToUserProfile(
                                                  uid: searchedUser.uid,
                                                  context: context);
                                            },
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                sendProjectInvite(
                                                    isInformation: false,
                                                    isProjectInvitation: true,
                                                    isTeamInvitation: false,
                                                    receiverId:
                                                        searchedUser.uid,
                                                    receiverName:
                                                        "${searchedUser.name} ${searchedUser.surname}",
                                                    senderId: user.uid,
                                                    senderName:
                                                        "${user.name} ${user.surname}",
                                                    projectTeamName:
                                                        projectInfo.title,
                                                    projectTeamId:
                                                        projectInfo.id,
                                                    context: context);
                                              },
                                              child: const Text("Davet Et"),
                                            ),
                                          )
                                        : Container(
                                            child: Text(
                                                "${searchedUser.name} ${searchedUser.surname}"),
                                          );
                                  },
                                  shrinkWrap: true,
                                );
                              },
                              error: (error, stackTrace) => ErrorText(
                                error: error.toString(),
                              ),
                              loading: () => const Loader(),
                            ),
                      ],
                    ));
              },
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );
  }
}
