import 'package:dating_app/authenticationScreen/registration_screen.dart';
import 'package:dating_app/controllers/authentication_controller.dart';
import 'package:dating_app/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppLocalizations.dart';
import '../ads/google_ads.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleAds _googleAds = GoogleAds();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool showProgressBar = false;
  var controllerAuth = AuthenticationController.authController;
  @override
  void initState() {
    super.initState();
    _googleAds.loadBannerAd(); // Bu şekilde düzeltin
  }

  Widget adWidget() {
    if (_googleAds.bannerAd == null) {
      return SizedBox(height: 0); // Reklam yüklenmediyse boş bir alan döndür
    }
    return Container(
      alignment: Alignment.center,
      width: _googleAds.bannerAd!.size.width.toDouble(),
      height: _googleAds.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _googleAds.bannerAd!),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Image.asset(
                "images/hearth7.png",
                width: 250,
              ),
              Text(
                AppLocalizations.of(context)!.translate("Wellcome"),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!
                    .translate("Login now to find your best Match"),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              //email
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: emailTextEditingController,
                  labelText: "Email",
                  iconData: Icons.email_outlined,
                  isObscure: false,
                ),
              ),

              //password
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: passwordTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Password"),
                  iconData: Icons.lock_open_outlined,
                  isObscure: true,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //login
              Container(
                width: MediaQuery.of(context).size.width - 36,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: InkWell(
                  onTap: () async {
                    if (emailTextEditingController.text.trim().isNotEmpty &&
                        passwordTextEditingController.text.trim().isNotEmpty) {
                      setState(() {
                        showProgressBar = true;
                      });

                      await controllerAuth.loginUser(
                          emailTextEditingController.text.trim(),
                          passwordTextEditingController.text.trim());

                      setState(() {
                        showProgressBar = false;
                      });
                    } else {
                      Get.snackbar(
                          AppLocalizations.of(context)!
                              .translate("Email or Password is Missing"),
                          AppLocalizations.of(context)!
                              .translate("Please fill all  fields."));
                    }
                  },
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate("Login"),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              //dont have an account create here button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .translate("Don't have an account? "),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(RegistrationScreen());
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("Create Here"),
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Privacy Policy link
              InkWell(
                onTap: () {
                  // URL'yi Gizlilik Politikanızın yer aldığı sayfaya yönlendirin
                  // Örneğin: 'https://example.com/privacy.html'
                  launchUrl(Uri.parse(
                      'https://dyuta6.github.io/privacy/privacy2.html'));
                },
                child: Text(
                  AppLocalizations.of(context)!.translate("Privacy Policy"),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors
                        .blue, // Bağlantıyı mavi yaparak daha belirgin hale getirin
                    decoration: TextDecoration
                        .underline, // Altını çizerek bağlantı olduğunu belirtin
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              showProgressBar == true
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 155, 146, 149)),
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),
              // adWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
