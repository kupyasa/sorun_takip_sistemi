import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/delegates/search_project_delegate.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/issue/controller/issue_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void navigateToNotifications({required BuildContext context}) {
    Routemaster.of(context).push("/notifications");
  }

  Icon getPriorityIcon(String priority) {
    if (priority == "Acil") {
      return const Icon(Icons.report_problem);
    } else if (priority == "Yüksek") {
      return const Icon(Icons.signal_cellular_alt);
    } else if (priority == "Orta") {
      return const Icon(Icons.signal_cellular_alt_2_bar);
    } else if (priority == "Düşük") {
      return const Icon(Icons.signal_cellular_alt_1_bar);
    } else {
      return const Icon(Icons.check);
    }
  }

  void navigateToIssueScreen(
      {required BuildContext context,
      required String projectId,
      required String issueId}) {
    Routemaster.of(context).push('/projects/$projectId/issues/$issueId');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anasayfa'),
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
                navigateToNotifications(context: context);
              },
              icon: const Icon(Icons.notifications),
            ),
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
            ref.watch(getProjectsOwnedByUserProvider(user.uid)).when(
                  data: (projects) {
                    return projects.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                            child: Column(
                              children: [
                                const Text(
                                  "Yöneticisi Olduğum Projeler",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final project = projects[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(project.projectPic),
                                        radius: 20,
                                      ),
                                      title: Text(project.title),
                                      onTap: () {
                                        Routemaster.of(context)
                                            .push('/projects/${project.id}');
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                ),
            ref.watch(getProjectsWhereUserIsMemberOfProvider(user.uid)).when(
                  data: (projects) {
                    return projects.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                            child: Column(
                              children: [
                                const Text("Üyesi Olduğum Projeler",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final project = projects[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(project.projectPic),
                                        radius: 20,
                                      ),
                                      title: Text(project.title),
                                      onTap: () {
                                        Routemaster.of(context)
                                            .push('/projects/${project.id}');
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const Loader(),
                ),
            ref.watch(getIssuesByUserProvider(user.uid)).when(
                data: (userIssues) {
                  return userIssues.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                          child: Column(
                            children: [
                              const Text("Bana Atanan Sorunlar",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              ListView.builder(
                                itemCount: userIssues.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final issue = userIssues.elementAt(index);
                                  return ListTile(
                                    leading: getPriorityIcon(issue.priority),
                                    title: Text(
                                      issue.title,
                                    ),
                                    subtitle: Column(children: [
                                      Text(
                                          "Oluşturuldu : ${DateFormat('dd-MMMM-yyyy HH:mm a', 'tr').format(issue.created)}"),
                                      Text(
                                          "Son Tarih : ${DateFormat('dd-MMMM-yyyy HH:mm a', 'tr').format(issue.due)}"),
                                    ]),
                                    onTap: () {
                                      navigateToIssueScreen(
                                        context: context,
                                        projectId: issue.projectId,
                                        issueId: issue.id,
                                      );
                                    },
                                  );
                                },
                                shrinkWrap: true,
                              )
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
                error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                loading: () => const Loader())
          ],
        ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );
  }
}
