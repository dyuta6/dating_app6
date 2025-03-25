import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/tabScreens/user_details_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //notifications arrived/received
  Future whenNotificationReceived(BuildContext context) async {
    //1.Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });
    //2.Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });
    //3.Background
    //When the app is in the background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });
  }

  openAppAndShowNotificationData(receiverID, senderID, context) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(senderID)
        .get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(senderID)
        .get()
        .then((snapshot) {
      String profileImage = snapshot.data()!["imageProfile"].toString();
      String name = snapshot.data()!["name"].toString();
      String age = snapshot.data()!["age"].toString();
      String city = snapshot.data()!["city"].toString();
      String country = snapshot.data()!["country"].toString();
      String profession = snapshot.data()!["profession"].toString();
      String featureType = "Like"; // Varsayılan bir değer

      showDialog(
          context: context,
          builder: (context) {
            return NotificationDialogBox(
              senderID,
              profileImage,
              name,
              age,
              city,
              country,
              profession,
              featureType,
              context,
            );
          });
    });
  }

  NotificationDialogBox(senderID, profileImage, name, age, city, country,
      profession, featureType, context) {
    // featureType'a göre özel metni tanımla
    String customMessage;
    if (featureType == "Like") {
      customMessage = "Bu kişi profilinize baktı";
    } else if (featureType == "View") {
      customMessage = "Bu kişi profilinize baktı";
    } else {
      customMessage = ""; // Veya varsayılan bir metin belirleyin
    }
    return Dialog(
      child: GridTile(
          child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: SizedBox(
          height: 300,
          child: Card(
            color: Colors.blue.shade200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(profileImage), fit: BoxFit.cover),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom message based on featureType
                      // name and age
                      Text(
                        customMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      //icon - city country location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Expanded(
                              child: Text(
                            city + ", " + country.toString(),
                            maxLines: 4,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ))
                        ],
                      ),
                      const Spacer(),
                      //2 button
                      Row(
                        children: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                Get.to(UserDetailsScreen(
                                  userID: senderID,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Profile Git"),
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text("Kapat"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Future generateDeviceRegistrationToken() async {
    String? deviceToken = await messaging.getToken();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .update({"userDeviceToken": deviceToken});
  }
}
