import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/issue/controller/issue_controller.dart';
import 'package:sorun_takip_sistemi/features/notification/controller/notification_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';
import 'package:sorun_takip_sistemi/model/user_model.dart';
import 'package:textfield_tags/textfield_tags.dart';

class CreateIssueScreen extends ConsumerStatefulWidget {
  final String projectId;

  const CreateIssueScreen({
    required this.projectId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends ConsumerState<CreateIssueScreen> {
  late String title;
  late String description;
  List<File>? _attachments;
  String priorityDropdownValue = "Acil";
  String assignedToDropdownValue = "Herkes";
  DateTime? due;

  List<DropdownMenuItem<String>> assignedToDropDownItems = [
    const DropdownMenuItem(value: "Herkes", child: Text("Herkes")),
  ];
  List<DropdownMenuItem<String>> prioritiesDropDownItems = [
    DropdownMenuItem(
      value: "Acil",
      child: Row(
        children: const [
          Icon(Icons.report_problem),
          SizedBox(
            width: 20,
          ),
          Text("Acil")
        ],
      ),
    ),
    DropdownMenuItem(
      value: "Yüksek",
      child: Row(
        children: const [
          Icon(Icons.signal_cellular_alt),
          SizedBox(
            width: 20,
          ),
          Text("Yüksek")
        ],
      ),
    ),
    DropdownMenuItem(
      value: "Orta",
      child: Row(
        children: const [
          Icon(Icons.signal_cellular_alt_2_bar),
          SizedBox(
            width: 20,
          ),
          Text("Orta")
        ],
      ),
    ),
    DropdownMenuItem(
      value: "Düşük",
      child: Row(
        children: const [
          Icon(Icons.signal_cellular_alt_1_bar),
          SizedBox(
            width: 20,
          ),
          Text("Düşük")
        ],
      ),
    ),
  ];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextfieldTagsController _labelsController = TextfieldTagsController();

  Future<void> createIssueAndSendNotification(
      {required String title,
      required String description,
      required List<File>? attachments,
      required String priority,
      required String assignedTo,
      required DateTime due,
      required List<String> labels,
      required BuildContext context}) async {
    final project =
        await ref.read(getProjectByIdFutureProvider(widget.projectId).future);
    final user = ref.read(userProvider)!;
    final projectMembers =
        await ref.read(getProjectMembersFutureProvider(project.members).future);

    if (assignedTo == "Herkes") {
      for (var assignedUser in projectMembers) {
        ref.watch(notificationControllerProvider.notifier).createNotification(
            isInformation: true,
            isProjectInvitation: false,
            isTeamInvitation: false,
            receiverId: assignedUser.uid,
            receiverName: "${assignedUser.name} ${assignedUser.surname}",
            senderId: user.uid,
            senderName: "${user.name} ${user.surname}",
            projectTeamName: project.title,
            projectTeamId: project.id,
            message:
                "Proje Yöneticisi ${user.name} ${user.surname} ${project.title} Projesine ${title} Sorununu ekledi.",
            context: context);
      }
    } else {
      final assignedUser =
          projectMembers.firstWhere((user) => user.uid == assignedTo);

      ref.watch(notificationControllerProvider.notifier).createNotification(
          isInformation: true,
          isProjectInvitation: false,
          isTeamInvitation: false,
          receiverId: assignedUser.uid,
          receiverName: "${assignedUser.name} ${assignedUser.surname}",
          senderId: user.uid,
          senderName: "${user.name} ${user.surname}",
          projectTeamName: project.title,
          projectTeamId: project.id,
          message:
              "Proje Yöneticisi ${user.name} ${user.surname} ${project.title} Projesine ${title} Sorununu ekledi.",
          context: context);
    }

    ref.watch(issueControllerProvider.notifier).createIssue(
        projectId: widget.projectId,
        assignedTo: assignedTo,
        priority: priority,
        labels: labels,
        due: due,
        attachments: attachments,
        title: title,
        description: description,
        context: context);
  }

  Future<void> getProjectMembers() async {
    final project =
        await ref.read(getProjectByIdFutureProvider(widget.projectId).future);

    final projectMembers =
        await ref.read(getProjectMembersFutureProvider(project.members).future);
    final newAssignedToDropDownItems = projectMembers.map((UserModel user) {
      return DropdownMenuItem<String>(
        value: user.uid,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
            ),
            const SizedBox(
              width: 20,
            ),
            Text("${user.name} ${user.surname}")
          ],
        ),
      );
    }).toList();
    assignedToDropDownItems.addAll(newAssignedToDropDownItems!);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descriptionController.dispose();

    _labelsController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    getProjectMembers();
    super.initState();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isLoading = ref.watch(issueControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sorun Oluştur'),
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
        body: isLoading
            ? const Loader()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Ekler",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var files = await pickFiles();
                          setState(() {
                            if (files != null) {
                              _attachments = files.paths
                                  .map((path) => File(path!))
                                  .toList();
                            }
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 60),
                          child: Center(
                              child: Icon(
                            Icons.folder,
                            color: Colors.blue,
                            size: 150,
                          )),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Sorun başlığını giriniz.",
                          labelText: "Sorun Başlık",
                        ),
                        controller: titleController,
                        onChanged: (val) {
                          setState(() {
                            title = val;
                          });
                          print(title);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        minLines: 5,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: "Sorun açıklamasını giriniz.",
                          labelText: "Sorun Açıklaması",
                        ),
                        controller: descriptionController,
                        onChanged: (val) {
                          setState(() {
                            description = val;
                          });
                          print(description);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Önem derecesini seçiniz.",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButton<String>(
                        value: priorityDropdownValue,
                        icon: const Icon(Icons.timer),
                        elevation: 16,
                        hint: const Text("Önem derecesini seçin."),
                        underline: Container(
                          height: 2,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            priorityDropdownValue = value!;
                          });
                          print(priorityDropdownValue);
                        },
                        items: prioritiesDropDownItems,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Atanacak kişiyi seçiniz.",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButton<String>(
                        value: assignedToDropdownValue,
                        icon: const Icon(Icons.person),
                        elevation: 16,
                        hint: const Text("Atanacak kişiyi seçin."),
                        underline: Container(
                          height: 2,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            assignedToDropdownValue = value!;
                          });
                          print(value);
                        },
                        items: assignedToDropDownItems,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFieldTags(
                        textfieldTagsController: _labelsController,
                        initialTags: const [],
                        textSeparators: const [' ', ','],
                        letterCase: LetterCase.normal,
                        validator: (String tag) {
                          if (_labelsController.getTags!.contains(tag)) {
                            return 'Etiket mevcut!';
                          }
                          return null;
                        },
                        inputfieldBuilder:
                            (context, tec, fn, error, onChanged, onSubmitted) {
                          return ((context, sc, tags, onTagDelete) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: tec,
                                focusNode: fn,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 74, 137, 92),
                                      width: 3.0,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 74, 137, 92),
                                      width: 3.0,
                                    ),
                                  ),
                                  helperText: 'Etiket girin.',
                                  helperStyle: const TextStyle(
                                    color: Color.fromARGB(255, 74, 137, 92),
                                  ),
                                  hintText: _labelsController.hasTags
                                      ? ''
                                      : "Etiket girin.",
                                  errorText: error,
                                  prefixIcon: tags.isNotEmpty
                                      ? SingleChildScrollView(
                                          controller: sc,
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                              children: tags.map((String tag) {
                                            return Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                                color: Color.fromARGB(
                                                    255, 74, 137, 92),
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    child: Text(
                                                      '#$tag',
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onTap: () {
                                                      print("$tag selected");
                                                    },
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  InkWell(
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      size: 14.0,
                                                      color: Color.fromARGB(
                                                          255, 233, 233, 233),
                                                    ),
                                                    onTap: () {
                                                      onTagDelete(tag);
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          }).toList()),
                                        )
                                      : null,
                                ),
                                onChanged: onChanged,
                                onSubmitted: onSubmitted,
                              ),
                            );
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          var datePicked =
                              await DatePicker.showSimpleDatePicker(
                            context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            dateFormat: "dd-MMMM-yyyy",
                            locale: DateTimePickerLocale.tr,
                            titleText: "Son Gün",
                            cancelText: "İPTAL",
                            confirmText: "TAMAM",
                          );
                          due = datePicked;
                        },
                        child: const Text(
                          'Tamamlanması Gereken Günü Seçin',
                        ),
                      ),
                      if (due != null) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "${DateFormat('dd-MMMM-yyyy HH:mm a', 'tr').format(due!)}",
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      ],
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Sorun Oluştur'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              titleController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty &&
                              _labelsController.hasTags &&
                              due != null) {
                            _labelsController.getTags!
                                .map((e) => print(e))
                                .toList();
                            createIssueAndSendNotification(
                                title: title,
                                description: description,
                                attachments: _attachments,
                                priority: priorityDropdownValue,
                                assignedTo: assignedToDropdownValue,
                                due: due!,
                                labels: _labelsController.getTags!,
                                context: context);
                          } else {
                            showSnackBar(context,
                                "Ekler dışındaki alanların doldurulması zorunludur.");
                          }
                          print(_labelsController.getTags!);
                          print(
                              _attachments != null ? _attachments!.length : 0);
                        },
                      ),
                    ],
                  ),
                ),
              ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );
  }
}
