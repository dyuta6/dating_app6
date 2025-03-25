import 'dart:io';

import 'package:dating_app/controllers/authentication_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppLocalizations.dart';
import '../widgets/custom_text_field_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  List<String> countries = [
    "Austria",
    "Brazil",
    "Canada",
    "China",
    "France",
    "Germany",
    "India",
    "Indonesia",
    "Italy",
    "Japan",
    "Mexico",
    "Netherlands",
    "Russia",
    "Saudi Arabia",
    "South Korea",
    "Spain",
    "Switzerland",
    "Turkey",
    "United Kingdom",
    "United States"
  ];
  List<String> genders = ["Male", "Female", "Others"];
  String? selectedCountry;
  String? selectedGender;
  //personal info
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();

  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();

  //Appearance
  TextEditingController heightTextEditingController = TextEditingController();
  TextEditingController weightTextEditingController = TextEditingController();

  //life style
  TextEditingController drinkTextEditingController = TextEditingController();
  TextEditingController smokeTextEditingController = TextEditingController();
  TextEditingController martialStatusTextEditingController =
      TextEditingController();

  TextEditingController professionTextEditingController =
      TextEditingController();

  TextEditingController livingSituationTextEditingController =
      TextEditingController();

  //background - cultural values

  TextEditingController educationTextEditingController =
      TextEditingController();

  TextEditingController religionTextEditingController = TextEditingController();
  TextEditingController ethnicityTextEditingController =
      TextEditingController();

  bool showProgressBar = false;

  var authenticationController = AuthenticationController.authController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                AppLocalizations.of(context)!.translate("Create Account"),
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.translate("to get Started Now"),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              //chose image circle avatar
              authenticationController.imageFile == null
                  ? const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage("images/logo2.png"),
                      backgroundColor: Colors.black,
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: FileImage(
                            File(authenticationController.imageFile!.path),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await authenticationController
                          .pickedImageFileFromGallery();
                      setState(() {
                        authenticationController.imageFile;
                      });
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await authenticationController
                          .captureImageFromPhoneCamera();
                      setState(() {
                        authenticationController.imageFile;
                      });
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              //personal info
              Text(
                AppLocalizations.of(context)!.translate("Personal Info:"),
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),
              //name
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: nameTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Name"),
                  iconData: Icons.person_outline,
                  isObscure: false,
                ),
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

              SizedBox(
                height: 20,
              ),
              //password
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
              //age
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: ageTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Age"),
                  iconData: Icons.numbers,
                  isObscure: false,
                ),
              ),

              SizedBox(
                height: 20,
              ),
              //Gender
              SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.translate("Gender"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag), // Add your icon here
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10), // Adjust padding
                    ),
                    value: selectedGender,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGender = newValue;
                      });
                    },
                    items: genders.map((String gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(
                          AppLocalizations.of(context)!.translate(gender),
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  )),

              SizedBox(
                height: 20,
              ),

              //city
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: cityTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("City"),
                  iconData: Icons.location_city,
                  isObscure: false,
                ),
              ),

              SizedBox(
                height: 20,
              ),
              //country
              SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.translate("Country"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag), // Add your icon here
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10), // Adjust padding
                    ),
                    value: selectedCountry,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCountry = newValue;
                      });
                    },
                    items: countries.map((String country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(
                          AppLocalizations.of(context)!.translate(country),
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  )),

              SizedBox(
                height: 20,
              ),

              //Appearance

              Text(
                AppLocalizations.of(context)!.translate("Appearance:"),
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),
              //height
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: heightTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Height"),
                  iconData: Icons.insert_chart,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //weight
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: weightTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Weight"),
                  iconData: Icons.table_chart,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //Life Style
              Text(
                AppLocalizations.of(context)!.translate("Life Style:"),
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),
              //drink
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: drinkTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Drink"),
                  iconData: Icons.local_drink_outlined,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //Smoke
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: smokeTextEditingController,
                  labelText: AppLocalizations.of(context)!.translate("Smoke"),
                  iconData: Icons.smoking_rooms,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //MartialStatus
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: martialStatusTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Marital Status"),
                  iconData: CupertinoIcons.person_2,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //profession
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: professionTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Profession"),
                  iconData: Icons.business_center,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //livingSituation
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: livingSituationTextEditingController,
                  labelText: AppLocalizations.of(context)!
                      .translate("Living Situation"),
                  iconData: CupertinoIcons.person_2_square_stack,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //Background-Culturel Values
              Text(
                AppLocalizations.of(context)!
                    .translate("Background-Culturel Values:"),
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 12,
              ),

              //Education
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: educationTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Education"),
                  iconData: Icons.history_edu,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //religion
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: religionTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Religion"),
                  iconData: CupertinoIcons.checkmark_seal_fill,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //ethnicity
              SizedBox(
                width: MediaQuery.of(context).size.width - 36,
                height: 55,
                child: CustomTextFieldWidget(
                  editingController: ethnicityTextEditingController,
                  labelText:
                      AppLocalizations.of(context)!.translate("Ethnicity"),
                  iconData: CupertinoIcons.eye,
                  isObscure: false,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //create account button
              Container(
                width: MediaQuery.of(context).size.width - 36,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: InkWell(
                  onTap: () async {
                    int userAge =
                        int.parse(ageTextEditingController.text.trim());
                    if (authenticationController.imageFile != null &&
                        userAge >= 18) {
                      if (
                          //personal info
                          nameTextEditingController.text.trim().isNotEmpty &&
                              emailTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              passwordTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              ageTextEditingController.text.trim().isNotEmpty &&
                              selectedCountry !=
                                  null && // Check for selected country

                              cityTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              selectedCountry !=
                                  null && // Check for selected country

                              //appearance
                              heightTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              weightTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&

                              //lifestyle
                              drinkTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              smokeTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              martialStatusTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              professionTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              livingSituationTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&

                              //background-cultural values

                              educationTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              religionTextEditingController.text
                                  .trim()
                                  .isNotEmpty &&
                              ethnicityTextEditingController.text
                                  .trim()
                                  .isNotEmpty) {
                        setState(() {
                          showProgressBar = true;
                        });
                        await authenticationController.createNewUserAccount(
                          //personal info
                          authenticationController.profileImage!,
                          emailTextEditingController.text.trim(),
                          passwordTextEditingController.text.trim(),
                          nameTextEditingController.text.trim(),
                          ageTextEditingController.text.trim(),
                          selectedGender!,

                          cityTextEditingController.text.trim(),
                          selectedCountry!, // Pass the selected country

                          //Appearance
                          heightTextEditingController.text.trim(),
                          weightTextEditingController.text.trim(),

                          //lifestyle
                          drinkTextEditingController.text.trim(),
                          smokeTextEditingController.text.trim(),
                          martialStatusTextEditingController.text.trim(),

                          professionTextEditingController.text.trim(),

                          livingSituationTextEditingController.text.trim(),

                          //Background-Culturel Values

                          educationTextEditingController.text.trim(),

                          religionTextEditingController.text.trim(),
                          ethnicityTextEditingController.text.trim(),
                        );

                        setState(() {
                          showProgressBar = false;
                          authenticationController.imageFile = null;
                        });
                      } else {
                        Get.snackbar(
                            AppLocalizations.of(context)!
                                .translate("A Field is Empty "),
                            AppLocalizations.of(context)!.translate(
                                "Please fill out all field in text fields."));
                      }
                    } else if (userAge < 18) {
                      Get.snackbar(
                          AppLocalizations.of(context)!
                              .translate("Age Requirement Not Met"),
                          AppLocalizations.of(context)!.translate(
                              "You must be at least 18 years old to register."));
                    } else {
                      Get.snackbar(
                          AppLocalizations.of(context)!
                              .translate("Image File Missing"),
                          AppLocalizations.of(context)!.translate(
                              "Please pick image from gallery or capture with Camera"));
                    }
                  },
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate("Create Account"),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //already have an account login here button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .translate("Already have an account?"),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("Login Here"),
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              showProgressBar == true
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
