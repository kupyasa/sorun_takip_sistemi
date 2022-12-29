import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class ProjectMembersScreen extends ConsumerWidget {
  final String projectId;

  const ProjectMembersScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void navigateToAddMembersToProjectScreen(BuildContext context) {
    Routemaster.of(context).push('/projects/$projectId/addmembers');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return ref.watch(getProjectByIdProvider(projectId)).when(
          data: (projectInfo) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Üyeler'),
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
                    if (projectInfo.owners.contains(user.uid)) ...[
                      IconButton(
                        onPressed: () {
                          navigateToAddMembersToProjectScreen(context);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
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
                    if (projectInfo.owners.isNotEmpty) ...[
                      ref
                          .watch(getProjectOwnersProvider(projectInfo.owners))
                          .when(
                            data: (projectOwners) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 25, 0, 10),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Proje Yöneticileri",
                                    ),
                                    ListView.builder(
                                      itemCount: projectOwners.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final owner = projectOwners[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(owner.profilePic),
                                            radius: 20,
                                          ),
                                          title: Text(
                                              "${owner.name} ${owner.surname}"),
                                          onTap: () {
                                            Routemaster.of(context)
                                                .push('/users/${owner.uid}');
                                          },
                                        );
                                      },
                                      shrinkWrap: true,
                                    )
                                  ],
                                ),
                              );
                            },
                            error: (error, stackTrace) => ErrorText(
                              error: error.toString(),
                            ),
                            loading: () => const Loader(),
                          ),
                    ],
                    if (projectInfo.members.isNotEmpty) ...[
                      ref
                          .watch(getProjectMembersProvider(projectInfo.members))
                          .when(
                            data: (projectMembers) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 25, 0, 10),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Proje Üyeleri",
                                    ),
                                    ListView.builder(
                                      itemCount: projectMembers.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final member = projectMembers[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(member.profilePic),
                                            radius: 20,
                                          ),
                                          title: Text(
                                              "${member.name} ${member.surname}"),
                                          trailing: projectInfo.owners
                                                  .contains(user.uid)
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            projectControllerProvider
                                                                .notifier)
                                                        .deleteMemberFromProject(
                                                          projectId: projectId,
                                                          memberId: member.uid,
                                                          context: context,
                                                        );
                                                  },
                                                  child: const Text(
                                                      "Projeden Çıkar"),
                                                )
                                              : null,
                                          onTap: () {
                                            Routemaster.of(context)
                                                .push('/users/${member.uid}');
                                          },
                                        );
                                      },
                                      shrinkWrap: true,
                                    )
                                  ],
                                ),
                              );
                            },
                            error: (error, stackTrace) => ErrorText(
                              error: error.toString(),
                            ),
                            loading: () => const Loader(),
                          ),
                    ]
                  ],
                ),
                drawer: const MenuDrawer(),
                endDrawer: const ProfileDrawer(),
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
