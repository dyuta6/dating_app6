import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/homeScreen/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/authentication_controller.dart';
import '../widgets/custom_text_field_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? currentProfileImageUrl;
  bool isUpdating = false;
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
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlList = [];
  double val = 0;

  //personal info
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();

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

  //personal info
  String name = '';
  String age = '';
  String gender = '';
  String phoneNo = '';
  String city = '';
  String country = '';

  //appearance
  String height = '';
  String weight = '';

  //Life style
  String drink = '';
  String smoke = '';
  String martialStatus = '';

  String profession = '';

  String livingSituation = '';

  //Background - Cultural Values

  String education = '';

  String religion = '';
  String ethnicity = '';

  chooseImage() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _image.add(File(PickedFile!.path));
    });
  }

  uploadImages() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      var refImages = FirebaseStorage.instance.ref().child(
          "images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");

      await refImages.putFile(img).whenComplete(() async {
        await refImages.getDownloadURL().then((urlImage) {
          urlList.add(urlImage);

          i++;
        });
      });
    }
  }

  retrieveUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          //personal info
          currentProfileImageUrl = snapshot.data()!['imageProfile'];
          name = snapshot.data()!['name'];
          nameTextEditingController.text = name;
          age = snapshot.data()!['age'].toString();
          ageTextEditingController.text = age;
          gender = snapshot.data()!['gender'].toString();
          selectedGender = gender;
          genderTextEditingController.text = gender;
          city = snapshot.data()!['city'];
          cityTextEditingController.text = city;
          country = snapshot.data()!['country'];
          selectedCountry = country;
          countryTextEditingController.text = country;

          //Appearance
          height = snapshot.data()!['height'];
          heightTextEditingController.text = height;
          weight = snapshot.data()!['weight'];
          weightTextEditingController.text = weight;

          //Life style
          drink = snapshot.data()!['drink'];
          drinkTextEditingController.text = drink;
          smoke = snapshot.data()!['smoke'];
          smokeTextEditingController.text = smoke;
          martialStatus = snapshot.data()!['martialStatus'];
          martialStatusTextEditingController.text = martialStatus;

          profession = snapshot.data()!['profession'];
          professionTextEditingController.text = profession;

          livingSituation = snapshot.data()!['livingSituation'];
          livingSituationTextEditingController.text = livingSituation;

          //Background Cultural Values

          education = snapshot.data()!['education'];
          educationTextEditingController.text = education;

          religion = snapshot.data()!['religion'];
          religionTextEditingController.text = religion;
          ethnicity = snapshot.data()!['ethnicity'];
          ethnicityTextEditingController.text = ethnicity;
        });
      }
    });
  }

  updateUserDataToFirestoreDatabase(
    //personal info
    String imageProfile,
    String name,
    String age,
    String gender,
    String city,
    String country,

    //appearance
    String height,
    String weight,

    //Life style
    String drink,
    String smoke,
    String martialStatus,
    String profession,
    String livingSituation,

    //Background - Culturel values

    String education,
    String religion,
    String ethnicity,
  ) async {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              height: 200,
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Yükleniyor..."),
                ],
              )),
            ),
          );
        });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .update({
      //personal info
      'imageProfile': imageProfile,
      'name': name,
      'age': int.parse(age),
      'gender': gender,
      'city': city,
      'country': country,

      //appearance
      'height': height,
      'weight': weight,

      //life style
      'drink': drink,
      'smoke': smoke,
      'martialStatus': martialStatus,

      'profession': profession,

      'livingSituation': livingSituation,

      //Background - cultural values

      'education': education,

      'religion': religion,
      'ethnicity': ethnicity,
    });

    Get.snackbar("Güncellendi", "Hesabınız başarılı bir şekilde güncellendi.");

    Get.to(const HomeScreen());

    setState(() {
      uploading = false;
      _image.clear();
      urlList.clear();
    });
  }

  void onCountryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCountry = newValue;
        countryTextEditingController.text = newValue; // TextField güncelleniyor
      });
    }
  }

  void onGenderChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedGender = newValue;
        genderTextEditingController.text = newValue; // TextField güncelleniyor
      });
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveUserData();
  }

  var authenticationController = AuthenticationController.authController;
  @override
  Widget build(BuildContext context) {
    Widget profileImage = authenticationController.imageFile == null
        ? (currentProfileImageUrl != null
            ? CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(currentProfileImageUrl!),
                backgroundColor: Colors.transparent,
              )
            : const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage("images/logo2.png"),
                backgroundColor: Colors.black,
              ))
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
            ));
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profil Bilgisi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [Container()],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 2,
                ),
                //chose image circle avatar
                profileImage,
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
                  "Kişisel Bilgi:",
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
                    labelText: "İsim",
                    iconData: Icons.person_outline,
                    isObscure: false,
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
                    labelText: "Yaş",
                    iconData: Icons.numbers,
                    isObscure: false,
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                //gender
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Cinsiyet",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_pin), // İkon ekleme
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    value: selectedGender,
                    onChanged:
                        onGenderChanged, // Burada fonksiyonumuzu atıyoruz
                    items: genders.map((String gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                //city
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: cityTextEditingController,
                    labelText: "Şehir",
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
                      labelText: "Ülke",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag), // İkon ekleme
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    value: selectedCountry,
                    onChanged:
                        onCountryChanged, // Burada fonksiyonumuzu atıyoruz
                    items: countries.map((String country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(
                          country,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                //Appearance

                Text(
                  "Dış Görünüş:",
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
                    labelText: "Boy",
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
                    labelText: "Kilo",
                    iconData: Icons.table_chart,
                    isObscure: false,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                //Life Style
                Text(
                  "Hayat Tarzı:",
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
                    labelText: "İçki",
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
                    labelText: "Sigara",
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
                    labelText: "Medeni Durum",
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
                    labelText: "Meslek",
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
                    labelText: "Kiminle Yaşıyorsun",
                    iconData: CupertinoIcons.person_2_square_stack,
                    isObscure: false,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                //Background-Culturel Values
                Text(
                  "Kültürel Değerler:",
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
                    labelText: "Eğitim",
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
                    labelText: "Din",
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
                    labelText: "Irk",
                    iconData: CupertinoIcons.eye,
                    isObscure: false,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 50,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: InkWell(
                    onTap: () async {
                      if (!isUpdating) {
                        setState(() {
                          isUpdating = true;
                        });

                        try {
                          String imageUrl;
                          if (authenticationController.imageFile != null) {
                            // Yeni resmi yükle ve URL'yi al
                            File imageFile =
                                File(authenticationController.imageFile!.path);
                            imageUrl = await authenticationController
                                .uploadImageToStorage(imageFile);
                          } else {
                            // Yeni resim seçilmemişse, mevcut resmin URL'sini kullan
                            imageUrl = currentProfileImageUrl ?? '';
                          }
                          if (
                              //personal info
                              nameTextEditingController.text
                                      .trim()
                                      .isNotEmpty &&
                                  ageTextEditingController.text
                                      .trim()
                                      .isNotEmpty &&
                                  genderTextEditingController.text
                                      .trim()
                                      .isNotEmpty &&
                                  cityTextEditingController.text
                                      .trim()
                                      .isNotEmpty &&
                                  countryTextEditingController.text
                                      .trim()
                                      .isNotEmpty &&

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
                            await updateUserDataToFirestoreDatabase(
                              //personal info
                              imageUrl,
                              nameTextEditingController.text.trim(),
                              ageTextEditingController.text.trim(),
                              genderTextEditingController.text.trim(),

                              cityTextEditingController.text.trim(),
                              countryTextEditingController.text.trim(),

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
                            // Güncelleme başarılıysa snackbar göster
                          } else {
                            Get.snackbar("Bir Alan Boş ",
                                "Lütfen tüm alanları doldurun.");
                          }
                        } catch (e) {
                          // Hata olursa kullanıcıya bilgi ver
                          Get.snackbar("Hata", "Fotoğraf yükleme hatası: $e");
                        }
                      }

                      setState(() {
                        isUpdating = false;
                      });
                    },
                    child: const Center(
                      child: Text(
                        "Güncelle",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ));
  }
}
