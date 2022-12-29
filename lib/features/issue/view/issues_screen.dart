import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/indicator.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/issue/controller/issue_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';
import 'package:sorun_takip_sistemi/model/issue_model.dart';

class ProjectIssuesScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectIssuesScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ProjectIssuesScreenState();
}

class _ProjectIssuesScreenState extends ConsumerState<ProjectIssuesScreen> {
  int touchedIndex = -1;

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void navigateToAddIssueToProjectScreen(BuildContext context) {
    Routemaster.of(context).push('/projects/${widget.projectId}/issues/create');
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
      {required BuildContext context, required String issueId}) {
    Routemaster.of(context)
        .push('/projects/${widget.projectId}/issues/$issueId');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return ref.watch(getProjectByIdProvider(widget.projectId)).when(
          data: (projectInfo) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Sorunlar'),
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
                          navigateToAddIssueToProjectScreen(context);
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
                body: ref
                    .watch(getIssuesByProjectProvider(widget.projectId))
                    .when(
                        data: (issues) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                            child: ListView(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: PieChart(
                                          PieChartData(
                                            pieTouchData: PieTouchData(
                                              touchCallback:
                                                  (FlTouchEvent event,
                                                      pieTouchResponse) {
                                                setState(() {
                                                  if (!event
                                                          .isInterestedForInteractions ||
                                                      pieTouchResponse ==
                                                          null ||
                                                      pieTouchResponse
                                                              .touchedSection ==
                                                          null) {
                                                    touchedIndex = -1;
                                                    return;
                                                  }
                                                  touchedIndex =
                                                      pieTouchResponse
                                                          .touchedSection!
                                                          .touchedSectionIndex;
                                                });
                                              },
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            sectionsSpace: 0,
                                            centerSpaceRadius: 40,
                                            sections: showingSections(issues),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Indicator(
                                          color: Color(0xff0293ee),
                                          text: 'Yapılacak',
                                          isSquare: true,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Indicator(
                                          color: Color(0xfff8b250),
                                          text: 'Yapılıyor',
                                          isSquare: true,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Indicator(
                                          color: Color(0xff845bef),
                                          text: 'Yapılmış',
                                          isSquare: true,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Indicator(
                                          color: Color(0xff13d38e),
                                          text: 'Askıda',
                                          isSquare: true,
                                        ),
                                        SizedBox(
                                          height: 18,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 28,
                                    ),
                                  ],
                                ),
                                const Center(
                                  child: Text("Yapılacaklar",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                                ListView.builder(
                                  itemCount: issues
                                      .where((issue) =>
                                          issue.status == "Yapılacak")
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final issue = issues
                                        .where((issue) =>
                                            issue.status == "Yapılacak")
                                        .elementAt(index);
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
                                          issueId: issue.id,
                                        );
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Center(
                                    child: Text(
                                  "Yapılıyor",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                                ListView.builder(
                                  itemCount: issues
                                      .where((issue) =>
                                          issue.status == "Yapılıyor")
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final issue = issues
                                        .where((issue) =>
                                            issue.status == "Yapılıyor")
                                        .elementAt(index);
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
                                          issueId: issue.id,
                                        );
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Center(
                                    child: Text(
                                  "Yapılmışlar",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                                ListView.builder(
                                  itemCount: issues
                                      .where(
                                          (issue) => issue.status == "Yapılmış")
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final issue = issues
                                        .where((issue) =>
                                            issue.status == "Yapılmış")
                                        .elementAt(index);
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
                                          issueId: issue.id,
                                        );
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Center(
                                    child: Text(
                                  "Askıda Olanlar",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                                ListView.builder(
                                  itemCount: issues
                                      .where(
                                          (issue) => issue.status == "Askıda")
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final issue = issues
                                        .where(
                                            (issue) => issue.status == "Askıda")
                                        .elementAt(index);
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
                                          issueId: issue.id,
                                        );
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                              ],
                            ),
                          );
                        },
                        error: (error, stackTrace) => ErrorText(
                              error: error.toString(),
                            ),
                        loading: () => const Loader()),
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

  List<PieChartSectionData> showingSections(List<IssueModel> issues) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: issues
                .where((issue) => issue.status == "Yapılacak")
                .length
                .toDouble(),
            title:
                '${(issues.where((issue) => issue.status == "Yapılacak").length / issues.length) * 100}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: issues
                .where((issue) => issue.status == "Yapılıyor")
                .length
                .toDouble(),
            title:
                '${(issues.where((issue) => issue.status == "Yapılıyor").length / issues.length) * 100}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: issues
                .where((issue) => issue.status == "Yapılmış")
                .length
                .toDouble(),
            title:
                '${(issues.where((issue) => issue.status == "Yapılmış").length / issues.length) * 100}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: issues
                .where((issue) => issue.status == "Askıda")
                .length
                .toDouble(),
            title:
                '${(issues.where((issue) => issue.status == "Askıda").length / issues.length) * 100}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
