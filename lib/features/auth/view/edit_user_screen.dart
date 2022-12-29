import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/drawers/menu_drawer.dart';
import 'package:sorun_takip_sistemi/core/drawers/profile_drawer.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  final String uid;

  const UserEditScreen({
    required this.uid,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  late String ad;
  late String soyad;
  late String telefon;
  late String adres;

  File? _profilFoto;

  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final adresController = TextEditingController();
  final telefonController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final user = ref.read(userProvider)!;
    adController.text = user.name;
    soyadController.text = user.surname;
    adresController.text = user.address;
    telefonController.text = user.phone;

    ad = user.name;
    soyad = user.surname;
    adres = user.address;
    telefon = user.phone;

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    adController.dispose();
    soyadController.dispose();
    adresController.dispose();
    telefonController.dispose();

    super.dispose();
  }

  void updateUser(
      {required String uid,
      required String name,
      required String surname,
      required String phone,
      required String address,
      File? profilePic,
      String? oldProfilePicURL,
      required BuildContext context}) {
    ref.read(authControllerProvider.notifier).updateUser(
          uid: uid,
          name: name,
          surname: surname,
          phone: phone,
          address: address,
          profilePic: profilePic,
          oldProfilePicURL: oldProfilePicURL,
          context: context,
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
    final isLoading = ref.watch(authControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kullanıcı Güncelle'),
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
            : ref.watch(getUserDataProvider(widget.uid)).when(
                  data: (userInfo) => SingleChildScrollView(
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
                                  _profilFoto = File(photo.files.single.path!);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
                              child: Center(
                                child: CircleAvatar(
                                  foregroundImage: _profilFoto == null
                                      ? NetworkImage(userInfo.profilePic)
                                          as ImageProvider
                                      : FileImage(_profilFoto!),
                                  radius: 100,
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Adınızı giriniz.",
                              labelText: "Ad",
                            ),
                            controller: adController,
                            onChanged: (val) {
                              setState(() {
                                ad = val;
                              });
                              print(ad);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Soyadınızı giriniz.",
                              labelText: "Soyad",
                            ),
                            controller: soyadController,
                            onChanged: (val) {
                              setState(() {
                                soyad = val;
                              });
                              print(soyad);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Telefon numaranızı giriniz.",
                              labelText: "Telefon Numarası",
                            ),
                            validator: (val) {
                              if ((val!.isEmpty) ||
                                  !RegExp(r"^(\d+)*$").hasMatch(val)) {
                                return "Geçerli bir telefon numarası girin";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            controller: telefonController,
                            onChanged: (val) {
                              setState(() {
                                telefon = val;
                              });
                              print(telefon);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Adresinizi giriniz.",
                              labelText: "Adres",
                            ),
                            controller: adresController,
                            onChanged: (val) {
                              setState(() {
                                adres = val;
                              });
                              print(adres);
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
                            child: const Text('Kullanıcıyı Güncelle'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                updateUser(
                                  uid: userInfo.uid,
                                  name: ad,
                                  surname: soyad,
                                  phone: telefon,
                                  address: adres,
                                  context: context,
                                  profilePic: _profilFoto,
                                  oldProfilePicURL: userInfo.profilePic,
                                );
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
