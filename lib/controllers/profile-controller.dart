import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/models/person.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Person;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../AppLocalizations.dart';
import '../main.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;

  var isLoading = false.obs;

  getResults() async {
    onInit();
  }

  @override
  void onInit() {
    super.onInit();
    listenToMessages();
    if (chosenGender != null && chosenCountry != null) {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("gender", isEqualTo: chosenGender.toString().toLowerCase())
          .where("country", isEqualTo: chosenCountry.toString())
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    } else if (chosenGender != null) {
      // Sadece gender seçilmişse
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("gender", isEqualTo: chosenGender.toString())
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    } else if (chosenCountry != null) {
      // Sadece country seçilmişse
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("country", isEqualTo: chosenCountry.toString())
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    } else {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    }
  }

  void listenToMessages() {
    // Uygulama başlatıldığında geçerli zamanı kaydedin
    DateTime lastCheckedTime = DateTime.now();

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messages")
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var timestamp = change.doc.data()!['timestamp'] as Timestamp;
          DateTime messageTime = timestamp.toDate();

          // Sadece lastCheckedTime'dan sonra gelen mesajlar için bildirim gönder
          if (messageTime.isAfter(lastCheckedTime)) {
            showNotification(change.doc.data()!['message']);
          }
        }
      }
    });
  }

  void showNotification(String message) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      AppLocalizations.of(Get.context!)!.translate('New Message'),
      message,
      generalNotificationDetails,
    );
  }

  favoriteSentAndFavoriteReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserID)
        .get();

    //remove the favorite from database
    if (document.exists) {
      //remove  currentUserID from the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .delete();

      //remove  [toUserID] from the favoriteSent list of the currentUserID
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("favoriteSent")
          .doc(toUserID)
          .delete();
    } else //mark as favorite // add favorite in database
    {
      //add currentUserID to the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .set({});

      //add [toUserID] to the favoriteSent list of the currentUserID
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("favoriteSent")
          .doc(toUserID)
          .set({});

      // send notification
      sendNotificationToUser(toUserID, "Favorite", senderName);
    }

    update();
  }

  likeSentAndLikeReceived(String toUserID, String senderName) async {
    // Görüntülenen profili 'viewReceived' listesine ekle ve bildirim gönder
    var documentReceived = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("likeReceived")
        .doc(currentUserID)
        .get();

    if (!documentReceived.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(currentUserID)
          .set({});

      // Bildirim yalnızca bu kısımda gönderilir
      sendNotificationToUser(toUserID, "Like", senderName);
    }

    // Görüntüleyen kullanıcının 'viewSent' listesine ekle
    var documentSent = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("likeSent")
        .doc(toUserID)
        .get();

    if (!documentSent.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("likeSent")
          .doc(toUserID)
          .set({});
    }

    update();
  }

  viewSentAndViewReceived(String toUserID, String senderName) async {
    // Kendi profilinize bakıyorsanız, işlemi durdurun
    if (toUserID == currentUserID) {
      return;
    }
    // Görüntülenen profili 'viewReceived' listesine ekle ve bildirim gönder
    var documentReceived = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("viewReceived")
        .doc(currentUserID)
        .get();

    if (!documentReceived.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("viewReceived")
          .doc(currentUserID)
          .set({});

      // Bildirim yalnızca bu kısımda gönderilir
      sendNotificationToUser(toUserID, "View", senderName);
    }

    // Görüntüleyen kullanıcının 'viewSent' listesine ekle
    var documentSent = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("viewSent")
        .doc(toUserID)
        .get();

    if (!documentSent.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("viewSent")
          .doc(toUserID)
          .set({});
    }

    update();
  }

  sendNotificationToUser(receiverID, featureType, senderName) async {
    String userDeviceToken = "";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(receiverID)
        .get()
        .then((snapshot) {
      if (snapshot.data()!["userDeviceToken"] != null) {
        userDeviceToken = snapshot.data()!["userDeviceToken"].toString();
      }
    });

    notificationFormat(userDeviceToken, receiverID, featureType, senderName);
  }

  notificationFormat(String userDeviceToken, String receiverID,
      String featureType, String senderName) {
    Map<String, String> headerNotification = {
      "Content-Type": "application/json",
      "Authorization":
          fcmServerToken, // Bu, Firebase Cloud Messaging sunucu tokenınız olmalı
    };
    Map bodyNotification = {
      "body": AppLocalizations.of(Get.context!)!
              .translate("you have received a new ") +
          "$featureType" +
          AppLocalizations.of(Get.context!)!.translate(" from ") +
          "$senderName." +
          AppLocalizations.of(Get.context!)!.translate("Click to see."),
      "title":
          AppLocalizations.of(Get.context!)!.translate("New") + "$featureType",
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userID": receiverID,
      "senderID": currentUserID,
      "featureType": featureType, // Burada featureType bilgisini ekliyoruz
    };
    Map notificationOfficalFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": userDeviceToken,
    };

    // HTTP isteği ile FCM API'ye bildirim gönder
    http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(notificationOfficalFormat),
    );
  }
}
