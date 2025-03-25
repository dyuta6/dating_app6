import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/chat.dart';
import 'package:dating_app/controllers/profile-controller.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/tabScreens/user_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppLocalizations.dart';
import '../models/person.dart';

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class SwippingScreen extends StatefulWidget {
  const SwippingScreen({super.key});

  @override
  State<SwippingScreen> createState() => _SwippingScreenState();
}

class _SwippingScreenState extends State<SwippingScreen> {
  ProfileController profileController = Get.put(ProfileController());
  String senderName = "";

  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 1);

  List<String> genderOptions = [
    "Male",
    "Female",
    "Others",
  ];

  List<String> countryOptions = [
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

  startChattingInWhatsApp(String receiverPhoneNumber) async {
    var androidUrl =
        "whatsapp://send?phone=$receiverPhoneNumber&text=Hi, I found your profile on dating app.";
    var iosUrl =
        "https://wa.me/$receiverPhoneNumber?text=${Uri.parse('Hi, I found your profile on dating app.')}";

    try {
      if (Platform.isIOS) {
        await launchUrl((Uri.parse(iosUrl)));
      } else {
        await launchUrl((Uri.parse(androidUrl)));
      }
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Whatsapp Not Found"),
              content: const Text("Whatsapp is not installed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  applyFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.translate("Matching Filter"),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!
                      .translate("I am looking for a:")),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      hint: Text(AppLocalizations.of(context)!
                          .translate("Select gender")),
                      value: chosenGender,
                      underline: Container(),
                      items: genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                              AppLocalizations.of(context)!.translate(value)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenGender = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(AppLocalizations.of(context)!.translate("who lives in")),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      hint: Text(AppLocalizations.of(context)!
                          .translate("Select country")),
                      value: chosenCountry,
                      underline: Container(),
                      items: countryOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                              AppLocalizations.of(context)!.translate(value)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenCountry = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      Get.back();

                      profileController.getResults();
                    },
                    child:
                        Text(AppLocalizations.of(context)!.translate("Done")))
              ],
            );
          });
        });
  }

  readCurrentUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get()
        .then((dataSnapshot) {
      setState(() {
        senderName = dataSnapshot.data()!["name"].toString();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readCurrentUserData();
  }

  @override
  void dispose() {
    pageController
        .dispose(); // Unutmayın, dispose metodunda PageController'ı temizleyin
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.translate("Swipping Screen")),
        centerTitle: true,
      ),
      body: Obx(() {
        if (profileController.allUsersProfileList.isEmpty) {
          // Profil listesi boşsa, kullanıcıya bir mesaj ve buton göster
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.translate(
                    "No profile matching the search criteria was found.")),
                ElevatedButton(
                  onPressed: () {
                    // Filtreleri null olarak ayarla
                    chosenGender = null;
                    chosenCountry = null;

                    // Bu kısımda applyFilter() içinde yapılan işlemleri yapın
                    // Örneğin, Firestore'dan veri çekme sorgusu
                    profileController.usersProfileList.bindStream(
                        FirebaseFirestore.instance
                            .collection("users")
                            .where("uid",
                                isNotEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots()
                            .map((QuerySnapshot queryDataSnapshot) {
                      List<Person> profilesList = [];
                      for (var eachProfile in queryDataSnapshot.docs) {
                        profilesList.add(Person.fromDataSnapshot(eachProfile));
                      }
                      return profilesList;
                    }));
                  },
                  child: Text(
                      AppLocalizations.of(context)!.translate("Reset Filters")),
                )
              ],
            ),
          );
        } else {
          return PageView.builder(
            itemCount: profileController.allUsersProfileList.length,
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final eachProfileInfo =
                  profileController.allUsersProfileList[index];

              return GestureDetector(
                onTap: () {
                  profileController.viewSentAndViewReceived(
                      eachProfileInfo.uid.toString(), senderName);

                  //send user to profile person userDetailScreen
                  Get.to(UserDetailsScreen(
                    userID: eachProfileInfo.uid,
                  ));
                },
                child: Stack(children: [
                  const Center(
                      child: CircularProgressIndicator()), // İndikatörü ortala
                  Positioned.fill(
                    child: FadeInImage.memoryNetwork(
                      placeholder:
                          kTransparentImage, // Şeffaf resim yine burada kullanılıyor.
                      image: eachProfileInfo.imageProfile.toString(),
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        //filter icon button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: IconButton(
                                onPressed: () {
                                  applyFilter();
                                },
                                icon: const Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        //user data
                        Column(
                          children: [
                            //name
                            ElevatedButton(
                              onPressed: () {
                                Get.to(UserDetailsScreen(
                                  userID: eachProfileInfo.uid,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white30,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                eachProfileInfo.name.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            //age-city
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white30,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                eachProfileInfo.age.toString() +
                                    " ◉ " +
                                    eachProfileInfo.city.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 14,
                        ),
                        //image buttons - favorite - chat - like
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //favorite button
                            GestureDetector(
                              onTap: () {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "images/x.png",
                                  width: 40,
                                ),
                              ),
                            ),
                            //chat button
                            GestureDetector(
                              onTap: () {
                                final eachProfileInfo = profileController
                                    .allUsersProfileList[index];
                                if (eachProfileInfo.uid != null) {
                                  Get.to(Chat(
                                    profileImage:
                                        eachProfileInfo.imageProfile.toString(),
                                    profileName:
                                        eachProfileInfo.name.toString(),
                                    profileUserId: eachProfileInfo
                                        .uid!, // Kullanıcının benzersiz ID'si
                                  ));
                                } else {
                                  // UID null ise hata mesajı göster veya başka bir işlem yap
                                  // Örnek: Hata mesajı gösterme
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .translate(
                                                  "User ID is not available.")),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "images/chat5.png",
                                  width: 50,
                                ),
                              ),
                            ),
                            //like button
                            GestureDetector(
                              onTap: () {
                                profileController.likeSentAndLikeReceived(
                                  eachProfileInfo.uid.toString(),
                                  senderName,
                                );
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "images/hearth2.png",
                                  width: 50,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            },
          );
        }
      }),
    );
  }
}
