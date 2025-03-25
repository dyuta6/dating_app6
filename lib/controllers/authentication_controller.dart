import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/homeScreen/home_screen.dart';
import 'package:dating_app/models/person.dart' as personModel;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../AppLocalizations.dart';
import '../authenticationScreen/login_screen.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController authController = Get.find();

  late Rx<User?> firebaseCurrentUser;

  late Rx<File?> pickedFile;
  File? get profileImage => pickedFile.value;
  XFile? imageFile;

  pickedImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Profile Image"),
          AppLocalizations.of(Get.context!)!.translate(
              "you have successfully picked your profile image from gallery"));
    }

    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  captureImageFromPhoneCamera() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Profile Image"),
          AppLocalizations.of(Get.context!)!.translate(
              "you have succesfully captured your profile image using camera"));
    }

    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference referenceStorage = FirebaseStorage.instance
        .ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = referenceStorage.putFile(imageFile);
    TaskSnapshot snapshot = await task;

    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();

    return downloadUrlOfImage;
  }

  createNewUserAccount(
    //personal info
    File imageProfile,
    String email,
    String password,
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
    try {
      //1. authenticate user and create User With Email And Password
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      //2. upload image to storage
      String urlOfDownloadedImage = await uploadImageToStorage(imageProfile);
      //3.save user info to firestore database
      personModel.Person personInstance = personModel.Person(
        //personal info
        uid: FirebaseAuth.instance.currentUser!.uid,
        imageProfile: urlOfDownloadedImage,
        email: email,
        password: password,
        name: name,
        age: int.parse(age),
        gender: gender,

        city: city,
        country: country,

        publishedDateTime: DateTime.now().millisecondsSinceEpoch,
        //appearance
        height: height,
        weight: weight,

        //lifestyle
        drink: drink,
        smoke: smoke,
        martialStatus: martialStatus,

        profession: profession,

        livingSituation: livingSituation,

        //Background - Culturel values

        education: education,

        religion: religion,
        ethnicity: ethnicity,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(personInstance.toJson());

      Get.snackbar(
          "Account Created", "Congratulations, your account has been created.");
      Get.to(const HomeScreen());
    } catch (errorMsg) {
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Account Creation Uns"),
          AppLocalizations.of(Get.context!)!.translate("Error occurred: ") +
              "$errorMsg");
    }
  }

  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailUser, password: passwordUser);
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Logged in Successful"),
          AppLocalizations.of(Get.context!)!
              .translate("you are logged in successfully."));
      Get.to(const HomeScreen());
    } catch (errorMsg) {
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Login Unsuccessful"),
          AppLocalizations.of(Get.context!)!.translate("Error occurred: ") +
              "$errorMsg");
    }
  }

  checkIfUserIsLoggedIn(User? currentUser) {
    if (currentUser == null) {
      Get.to(const LoginScreen());
    } else {
      Get.to(const HomeScreen());
    }
  }

  Future<void> confirmDeleteAccount() async {
    // Diyalog kutusunu göster
    bool? confirm = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Delete Account")),
        content: Text(AppLocalizations.of(context)!.translate(
            'Are you sure you want to delete your account? This action cannot be undone.')),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // false değeriyle dön
            child: Text(AppLocalizations.of(context)!.translate("No")),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // true değeriyle dön
            child: Text(AppLocalizations.of(context)!.translate("Yes")),
          ),
        ],
      ),
    );

    // Kullanıcı 'Evet' dediyse, hesabı sil
    if (confirm == true) {
      await deleteAccount();
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Firebase Authentication'dan mevcut kullanıcıyı al
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Firestore'daki kullanıcı verilerini sil
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .delete();

        // Firebase Authentication'dan kullanıcıyı sil
        await currentUser.delete();

        // Kullanıcıyı başarıyla sildikten sonra giriş ekranına yönlendir
        Get.offAll(() => const LoginScreen());
        Get.snackbar(
            AppLocalizations.of(Get.context!)!.translate("Account Deleted"),
            AppLocalizations.of(Get.context!)!
                .translate("Your account has been successfully deleted."));
      }
    } catch (error) {
      // Hata durumunda hata mesajını göster
      Get.snackbar(
          AppLocalizations.of(Get.context!)!.translate("Mistake"),
          AppLocalizations.of(Get.context!)!
                  .translate("An error occurred while deleting the account: ") +
              "$error");
    }
  }

  @override
  void onReady() {
    super.onReady();

    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    ever(firebaseCurrentUser, checkIfUserIsLoggedIn);
  }
}
