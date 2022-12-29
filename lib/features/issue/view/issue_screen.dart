import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/comment/controller/comment_controller.dart';
import 'package:sorun_takip_sistemi/features/issue/controller/issue_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueScreen extends ConsumerStatefulWidget {
  final String projectId;

  final String issueId;

  const IssueScreen({
    required this.projectId,
    required this.issueId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _IssueScreenState();
}

class _IssueScreenState extends ConsumerState<IssueScreen> {
  late String message;
  List<File>? _attachments;
  final messageController = TextEditingController();

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
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

  Icon getStatusIcon(String priority) {
    if (priority == "Askıda") {
      return const Icon(Icons.ac_unit);
    } else if (priority == "Yapılacak") {
      return const Icon(Icons.circle_outlined);
    } else if (priority == "Yapılıyor") {
      return const Icon(Icons.circle);
    } else {
      return const Icon(Icons.check_circle);
    }
  }

  void navigateToEditIssueScreen(context) {
    Routemaster.of(context)
        .push('/projects/${widget.projectId}/issues/${widget.issueId}/edit');
  }

  void createComment(
      {required String projectTeamId,
      required String? issueId,
      required String senderName,
      required String senderId,
      required String message,
      required List<File>? attachments,
      required BuildContext context}) {
    ref.watch(commentControllerProvider.notifier).createComment(
        projectTeamId: projectTeamId,
        issueId: issueId,
        senderName: senderName,
        senderId: senderId,
        message: message,
        attachments: attachments,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    var isCommentLoading = ref.watch(commentControllerProvider);
    return ref.watch(getProjectByIdProvider(widget.projectId)).when(
          data: (projectInfo) {
            return ref.watch(getIssueByIdProvider(widget.issueId)).when(
                data: (issue) {
                  return SafeArea(
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Sorun'),
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
                              createPDFforIssue(
                                issue: issue,
                                context: context,
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf),
                          ),
                          if (projectInfo.owners.contains(user.uid) ||
                              issue.assignedTo == user.uid ||
                              issue.assignedTo == "Herkes") ...[
                            IconButton(
                              onPressed: () {
                                navigateToEditIssueScreen(context);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                          Builder(
                            builder: (context) {
                              return IconButton(
                                icon: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                ),
                                onPressed: () => displayEndDrawer(context),
                              );
                            },
                          ),
                        ],
                      ),
                      body: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 20, 10, 5),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  Card(
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            issue.title,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(issue.description),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Önem Derecesi : "),
                                              Text("${issue.priority} "),
                                              getPriorityIcon(issue.priority)
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Durum : "),
                                              Text("${issue.status} "),
                                              getStatusIcon(issue.status)
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text("Oluşturulma Tarihi : "),
                                              Text(
                                                  "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.created)} "),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text("Son Tarih : "),
                                              Text(
                                                  "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.due)} "),
                                            ],
                                          ),
                                        ),
                                        if (issue.completed != null) ...[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text(
                                                    "Tamamlanma Tarihi : "),
                                                Text(
                                                    "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.completed!)} "),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (issue.labels.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: List<Widget>.generate(
                                                issue.labels.length,
                                                (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Chip(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 5, 5, 5),
                                                    label: Text(
                                                        "#${issue.labels.elementAt(index)}"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (issue.attachments.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: List<Widget>.generate(
                                                issue.attachments.length,
                                                (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: ElevatedButton(
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.folder),
                                                        Text(" Ek ${index + 1}")
                                                      ],
                                                    ),
                                                    onPressed: () async {
                                                      if (!await launchUrl(
                                                          Uri.parse(
                                                            issue.attachments
                                                                .elementAt(
                                                                    index),
                                                          ),
                                                          mode: LaunchMode
                                                              .externalApplication)) {
                                                        showSnackBar(context,
                                                            "URL açılamadı");
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  ref
                                      .watch(
                                          getCommentsByIssueProvider(issue.id))
                                      .when(
                                        data: (comments) {
                                          return Column(
                                            children: List<Widget>.generate(
                                              comments.length,
                                              (index) {
                                                return Card(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: (projectInfo
                                                                    .owners
                                                                    .contains(user
                                                                        .uid) ||
                                                                user.uid ==
                                                                    comments
                                                                        .elementAt(
                                                                            index)
                                                                        .senderId)
                                                            ? IconButton(
                                                                icon: const Icon(
                                                                    Icons
                                                                        .close),
                                                                iconSize: 20.0,
                                                                onPressed: () {
                                                                  ref.read(commentControllerProvider.notifier).deleteComment(
                                                                      id: comments
                                                                          .elementAt(
                                                                              index)
                                                                          .id,
                                                                      context:
                                                                          context);
                                                                },
                                                              )
                                                            : null,
                                                        title: Text(comments
                                                            .elementAt(index)
                                                            .senderName),
                                                        subtitle: Text(comments
                                                            .elementAt(index)
                                                            .message),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: List<
                                                            Widget>.generate(
                                                          comments
                                                              .elementAt(index)
                                                              .attachments
                                                              .length,
                                                          (indexInside) =>
                                                              Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child:
                                                                ElevatedButton(
                                                              child: Row(
                                                                children: [
                                                                  const Icon(Icons
                                                                      .folder),
                                                                  Text(
                                                                      " Ek ${indexInside + 1}")
                                                                ],
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                if (!await launchUrl(
                                                                    Uri.parse(
                                                                      comments
                                                                          .elementAt(
                                                                              index)
                                                                          .attachments
                                                                          .elementAt(
                                                                              indexInside),
                                                                    ),
                                                                    mode: LaunchMode
                                                                        .externalApplication)) {
                                                                  showSnackBar(
                                                                      context,
                                                                      "URL açılamadı");
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Text(
                                                                "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(comments.elementAt(index).created)} "),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        error: (error, stackTrace) => ErrorText(
                                          error: error.toString(),
                                        ),
                                        loading: () => const Loader(),
                                      )
                                ],
                              ),
                            ),
                            isCommentLoading
                                ? const Loader()
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: messageController,
                                            maxLines: 2,
                                            minLines: 1,
                                            autocorrect: true,
                                            decoration: const InputDecoration(
                                              labelText: "Yorum",
                                              labelStyle: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                message = value;
                                              });
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.folder),
                                          iconSize: 20.0,
                                          onPressed: () async {
                                            var files = await pickFiles();
                                            setState(() {
                                              if (files != null) {
                                                _attachments = files.paths
                                                    .map((path) => File(path!))
                                                    .toList();
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.send),
                                          iconSize: 20.0,
                                          onPressed: () {
                                            if (messageController
                                                .text.isNotEmpty) {
                                              createComment(
                                                  projectTeamId: projectInfo.id,
                                                  issueId: issue.id,
                                                  senderName:
                                                      "${user.name} ${user.surname}",
                                                  senderId: user.uid,
                                                  message: message.trim(),
                                                  attachments: _attachments,
                                                  context: context);
                                              messageController.text = "";
                                            } else {
                                              showSnackBar(context,
                                                  "Mesaj boş bırakılamaz!");
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      drawer: const MenuDrawer(),
                      endDrawer: const ProfileDrawer(),
                    ),
                  );
                },
                error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                loading: () => const Loader());
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
