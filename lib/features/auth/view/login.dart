import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late String eposta;
  late String sifre;

  final epostaController = TextEditingController();
  final sifreController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void logIn(BuildContext context, {email, password}) {
    ref.read(authControllerProvider.notifier).logIn(
          context,
          email: email,
          password: password,
        );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    epostaController.dispose();
    sifreController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Giriş Yap"),
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
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "E-posta adresinizi giriniz",
                          labelText: "E-posta adresi",
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
                      const SizedBox(
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
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Şifre bölümü boş bırakılamaz";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        child: const Text('Giriş Yap'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            logIn(
                              context,
                              email: eposta,
                              password: sifre,
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: const Text('Kayıt Ol'),
                        onPressed: () {
                          Routemaster.of(context).push('/register');
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: const Text('Şifremi Unuttum'),
                        onPressed: () {
                          Routemaster.of(context).push('/forgot-password');
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
