import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/delegates/search_project_delegate.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class ProjectScreen extends ConsumerWidget {
  final String projectId;
  const ProjectScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void navigateToEditProjectScreen(context) {
    Routemaster.of(context).push('/projects/$projectId/edit');
  }

  void navigateToProjectMembersScreen(context) {
    Routemaster.of(context).push('/projects/$projectId/members');
  }

  void navigateToProjectIssuesScreen(context) {
    Routemaster.of(context).push('/projects/$projectId/issues');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return ref.watch(getProjectByIdProvider(projectId)).when(
          data: (project) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Proje'),
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
                    IconButton(
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: SearchProjectDelegate(ref: ref));
                      },
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () {
                        createPDFforProject(
                          project: project,
                          context: context,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                    ),
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: CircleAvatar(
                            backgroundImage: NetworkImage(
                              ref.watch(userProvider)!.profilePic,
                            ),
                          ),
                          onPressed: () => displayEndDrawer(context),
                        );
                      },
                    ),
                  ],
                ),
                body: ListView(
                  children: [
                    Image.network(
                      project.projectPic,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            project.title,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (project.owners.contains(user.uid)) ...[
                            OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Projeyi Düzenle"),
                              onPressed: () async {
                                navigateToEditProjectScreen(context);
                              },
                            )
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${project.members.length + project.owners.length} Üye",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Üyeler",
                            ),
                            onPressed: () async {
                              navigateToProjectMembersScreen(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(
                        "Açıklama \n${project.description}",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (project.members.contains(user.uid) ||
                        project.owners.contains(user.uid)) ...[
                      Padding(
                        padding: const EdgeInsets.all(50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Sorunlar Sayfası'),
                          onPressed: () {
                            navigateToProjectIssuesScreen(context);
                          },
                        ),
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
    /*return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Proje'),
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
            IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SearchProjectDelegate(ref: ref));
              },
              icon: const Icon(Icons.search),
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage(
                      ref.watch(userProvider)!.profilePic,
                    ),
                  ),
                  onPressed: () => displayEndDrawer(context),
                );
              },
            ),
          ],
        ),
        body: ref.watch(getProjectByIdProvider(projectId)).when(
              data: (project) {
                return ListView(
                  children: [
                    Image.network(
                      project.projectPic,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(project.title),
                          if (project.owners.contains(user.uid)) ...[
                            OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Projeyi Düzenle"),
                              onPressed: () async {
                                navigateToEditProjectScreen(context);
                              },
                            )
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${project.members.length + project.owners.length} Üye"),
                          OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Üyeler"),
                            onPressed: () async {
                              navigateToProjectMembersScreen(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text("Açıklama \n${project.description}"),
                    ),
                    if (project.members.contains(user.uid) ||
                        project.owners.contains(user.uid)) ...[
                      Padding(
                        padding: const EdgeInsets.all(50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Sorunlar Sayfası'),
                          onPressed: () {
                            navigateToProjectIssuesScreen(context);
                          },
                        ),
                      ),
                    ]
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );*/
  }
}
