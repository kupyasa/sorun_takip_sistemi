import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/delegates/search_project_delegate.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final String projectId;
  const EditProjectScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  String? title;
  String? description;
  File? _projectPic;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    final project = ref.read(getProjectByIdProvider(widget.projectId)).value;
    title = project!.title;
    description = project.description;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  void updateProject(
      {required String projectId,
      required String title,
      required String description,
      File? projectPic,
      String? oldProjectPicURL,
      required BuildContext context}) {
    ref.read(projectControllerProvider.notifier).updateProject(
        projectId: projectId,
        title: title,
        description: description,
        projectPic: projectPic,
        oldProjectPicURL: oldProjectPicURL,
        context: context);
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
    final isLoading = ref.watch(projectControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projeyi Düzenle'),
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
            : ref.watch(getProjectByIdProvider(widget.projectId)).when(
                  data: (project) => SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var photo = await pickImage();
                              setState(() {
                                if (photo != null) {
                                  _projectPic = File(photo.files.single.path!);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
                              child: Center(
                                child: CircleAvatar(
                                  foregroundImage: _projectPic == null
                                      ? NetworkImage(project.projectPic)
                                          as ImageProvider
                                      : FileImage(_projectPic!),
                                  radius: 100,
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            initialValue: project.title,
                            decoration: const InputDecoration(
                              hintText: "Proje başlığını giriniz.",
                              labelText: "Proje Başlık",
                            ),
                            onChanged: (val) {
                              setState(() {
                                title = val;
                              });
                              print(title);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            initialValue: project.description,
                            minLines: 5,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: "Proje açıklamasını giriniz.",
                              labelText: "Proje Açıklaması",
                            ),
                            onChanged: (val) {
                              setState(() {
                                description = val;
                              });
                              print(description);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Projeyi Düzenle'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (title != null && description != null) {
                                  updateProject(
                                    projectId: project.id,
                                    title: title!,
                                    description: description!,
                                    projectPic: _projectPic,
                                    oldProjectPicURL: project.projectPic,
                                    context: context,
                                  );
                                } else {
                                  showSnackBar(
                                    context,
                                    "Başlık ve açıklamada değişiklik yapılması zorunludur.",
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
        drawer: const MenuDrawer(),
        endDrawer: const ProfileDrawer(),
      ),
    );
  }
}
