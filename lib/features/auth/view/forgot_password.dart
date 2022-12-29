import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late String eposta;

  final epostaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void sendPasswordResetLink({
    required BuildContext context,
    required String email,
  }) {
    ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetLink(email: email, context: context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    epostaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Şifremi Unuttum"),
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
                      ElevatedButton(
                        child: const Text('Şifre Sıfırlama Epostasını Gönder'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            sendPasswordResetLink(
                                context: context, email: eposta);
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: const Text('Girişe Geri Dön'),
                        onPressed: () {
                          Routemaster.of(context).push('/');
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
