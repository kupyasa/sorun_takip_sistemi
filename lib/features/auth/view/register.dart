import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/core/utils.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<RegisterScreen> {
  late String eposta;
  late String sifre;
  late String ad;
  late String soyad;
  late String telefon;
  late String adres;
  late String sifreTekrar;

  File? _profilFoto;

  final epostaController = TextEditingController();
  final sifreController = TextEditingController();
  final sifreTekrarController = TextEditingController();
  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final adresController = TextEditingController();
  final telefonController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    epostaController.dispose();
    sifreController.dispose();
    sifreTekrarController.dispose();
    adController.dispose();
    soyadController.dispose();
    adresController.dispose();
    telefonController.dispose();

    super.dispose();
  }

  void signIn(
    BuildContext context, {
    email,
    password,
    name,
    surname,
    phone,
    address,
    profilePicFile,
  }) {
    ref.read(authControllerProvider.notifier).signIn(
          context,
          email: email,
          password: password,
          name: name,
          surname: surname,
          phone: phone,
          address: address,
          profilePicFile: profilePicFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kayıt Ol"),
        ),
        body: isLoading
            ? const Center(
                child: Loader(),
              )
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
                              _profilFoto = File(photo.files.single.path!);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
                          child: Center(
                            child: _profilFoto == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 150,
                                  )
                                : CircleAvatar(
                                    foregroundImage: FileImage(_profilFoto!),
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
                          hintText: "E-posta adresinizi giriniz",
                          labelText: "E-posta Adresi",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if ((val!.isEmpty) ||
                              !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                  .hasMatch(val)) {
                            return "Geçerli bir e-posta adresi girin";
                          }
                          return null;
                        },
                        controller: epostaController,
                        onChanged: (val) {
                          setState(() {
                            eposta = val;
                          });
                          print(eposta);
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
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Şifrenizi giriniz.",
                          labelText: "Şifre",
                        ),
                        obscureText: true,
                        controller: sifreController,
                        onChanged: (val) {
                          setState(() {
                            sifre = val;
                          });
                          print(sifre);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Şifrenizi tekrar giriniz.",
                          labelText: "Şifre Tekrar",
                        ),
                        obscureText: true,
                        controller: sifreTekrarController,
                        onChanged: (val) {
                          setState(() {
                            sifreTekrar = val;
                          });
                          print(sifreTekrar);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        child: const Text('Kayıt Ol'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              sifre == sifreTekrar &&
                              eposta.isNotEmpty &&
                              sifre.isNotEmpty &&
                              sifreTekrar.isNotEmpty &&
                              ad.isNotEmpty &&
                              soyad.isNotEmpty &&
                              telefon.isNotEmpty &&
                              adres.isNotEmpty) {
                            signIn(context,
                                email: eposta,
                                password: sifre,
                                name: ad,
                                surname: soyad,
                                phone: telefon,
                                address: adres,
                                profilePicFile: _profilFoto);
                          } else {
                            showSnackBar(context,
                                "Profil fotoğrafı dışında alanların girilmesi zorunludur.");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
