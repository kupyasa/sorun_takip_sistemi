import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/delegates/search_project_delegate.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  late String title;
  late String description;
  File? _projectPic;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  void createProject(
      {required String title,
      required String description,
      File? projectPic,
      required BuildContext context}) {
    ref.watch(projectControllerProvider.notifier).createProject(
          title: title,
          description: description,
          context: context,
          projectPic: projectPic,
        );
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
          title: const Text('Proje Oluştur'),
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
                            child: _projectPic == null
                                ? const Icon(
                                    Icons.folder,
                                    color: Colors.blue,
                                    size: 150,
                                  )
                                : CircleAvatar(
                                    foregroundImage: FileImage(_projectPic!),
                                    radius: 100,
                                  ),
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Proje başlığını giriniz.",
                          labelText: "Proje Başlık",
                        ),
                        controller: titleController,
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
                        minLines: 5,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: "Proje açıklamasını giriniz.",
                          labelText: "Proje Açıklaması",
                        ),
                        controller: descriptionController,
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
                        child: const Text('Proje Oluştur'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _projectPic != null &&
                              titleController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty) {
                            createProject(
                              title: title,
                              description: description,
                              context: context,
                              projectPic: _projectPic,
                            );
                          }
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
