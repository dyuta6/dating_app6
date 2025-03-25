import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/accountSettingScreen/account_settings_screen.dart';
import 'package:dating_app/chat.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/homeScreen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDetailsScreen extends StatefulWidget {
  String? userID;
  UserDetailsScreen({super.key, this.userID});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String profileImageUrl = '';
//personal info
  String name = '';
  String age = '';
  String gender = '';

  String city = '';
  String country = '';

  //appearance
  String height = '';
  String weight = '';

//life style
  String drink = '';
  String smoke = '';
  String martialStatus = '';

  String profession = '';

  String livingSituation = '';

//Background - Culturel values

  String education = '';

  String religion = '';
  String ethnicity = '';

  //slider images
  String urlImage1 =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-3bee4.appspot.com/o/Place%20Holder%2Flogo2.png?alt=media&token=6645d292-7312-4f51-b24e-230db04f15a3';
  String urlImage2 =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-3bee4.appspot.com/o/Place%20Holder%2Flogo2.png?alt=media&token=6645d292-7312-4f51-b24e-230db04f15a3';
  String urlImage3 =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-3bee4.appspot.com/o/Place%20Holder%2Flogo2.png?alt=media&token=6645d292-7312-4f51-b24e-230db04f15a3';
  String urlImage4 =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-3bee4.appspot.com/o/Place%20Holder%2Flogo2.png?alt=media&token=6645d292-7312-4f51-b24e-230db04f15a3';
  String urlImage5 =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-3bee4.appspot.com/o/Place%20Holder%2Flogo2.png?alt=media&token=6645d292-7312-4f51-b24e-230db04f15a3';

  retrieveUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          //personal info
          // Retrieve the profile image URL from Firestore
          profileImageUrl = snapshot.data()!["imageProfile"];
          name = snapshot.data()!["name"];
          age = snapshot.data()!["age"].toString();
          gender = snapshot.data()!["gender"];

          city = snapshot.data()!["city"];
          country = snapshot.data()!["country"];

          //appearance
          height = snapshot.data()!["height"];
          weight = snapshot.data()!["weight"];

          //Life style
          drink = snapshot.data()!["drink"];
          smoke = snapshot.data()!["smoke"];
          martialStatus = snapshot.data()!["martialStatus"];

          profession = snapshot.data()!["profession"];

          livingSituation = snapshot.data()!["livingSituation"];

          //Background-cultural values

          education = snapshot.data()!["education"];

          religion = snapshot.data()!["religion"];
          ethnicity = snapshot.data()!["ethnicity"];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: widget.userID != currentUserID
            ? IconButton(
                onPressed: () {
                  Get.to(HomeScreen());
                },
                icon: const Icon(
                  Icons.arrow_back_outlined,
                  size: 30,
                ))
            : Container(),
        actions: [
          //koşula bağlı olarak chat iconu ekleme
          widget.userID != currentUserID
              ? IconButton(
                  onPressed: () {
                    Get.to(Chat(
                        profileImage: profileImageUrl,
                        profileName: name,
                        profileUserId: widget.userID.toString()));
                  },
                  icon: const Icon(Icons.chat),
                )
              : Container(),
          widget.userID == currentUserID
              ? Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.to(AccountSettingsScreen());
                        },
                        icon: const Icon(
                          Icons.settings,
                          size: 30,
                        )),
                    IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 30,
                        )),
                  ],
                )
              : Container(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              //image slider
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.network(
                      profileImageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null)
                          return child; // Image is fully loaded, return the image widget
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null, // This will show the current progress of the image loading
                          ),
                        );
                      },
                      errorBuilder: (context, error, StackTrace) {
                        return Center(
                            child:
                                SizedBox(child: CircularProgressIndicator()));
                      },
                    )),
              ),
              const SizedBox(
                height: 10.0,
              ),
              //personal info title
              const SizedBox(
                height: 30.0,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Profil Bilgisi:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),
              //personal info table data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    //name
                    TableRow(children: [
                      const Text(
                        "İsim: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //age
                    TableRow(children: [
                      const Text(
                        "Yaş: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        age,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                    //gender
                    TableRow(children: [
                      const Text(
                        "Cinsiyet: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        gender,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //city
                    TableRow(children: [
                      const Text(
                        "Şehir: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //country
                    TableRow(children: [
                      const Text(
                        "Ülke: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        country,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                  ],
                ),
              ),
              //appearance title
              const SizedBox(
                height: 30.0,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Dış görünüş:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),
              //appearance table data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    //height
                    TableRow(children: [
                      const Text(
                        "Boy: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        height,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //weight
                    TableRow(children: [
                      const Text(
                        "Kilo: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        weight,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),

                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                  ],
                ),
              ),
              //Life Style Title
              const SizedBox(
                height: 30.0,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Yaşam Tarzı:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),

              //Life Style Table Data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    //Drink
                    TableRow(children: [
                      const Text(
                        "İçki : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        drink,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                    //Smoke
                    TableRow(children: [
                      const Text(
                        "Sigara : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        smoke,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                    //martialStatus
                    TableRow(children: [
                      const Text(
                        "Medeni hal : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        martialStatus,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //profession
                    TableRow(children: [
                      const Text(
                        "Meslek : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        profession,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //livingSituation
                    TableRow(children: [
                      const Text(
                        "Kiminle Yaşıyorsun  : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        livingSituation,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                  ],
                ),
              ),

              //Background - Cultural ValuesTitle
              const SizedBox(
                height: 30.0,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Kültürel Değerler:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),

              //Background - Cultural Values Data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    //education
                    TableRow(children: [
                      const Text(
                        "Eğitim: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        education,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //religion
                    TableRow(children: [
                      const Text(
                        "Din: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        religion,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),

                    //ethnicity
                    TableRow(children: [
                      const Text(
                        "Millet: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        ethnicity,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ]),
                    //extra row
                    TableRow(children: [
                      Text(""),
                      Text(""),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
