import 'package:firebase_auth/firebase_auth.dart';

String currentUserID = FirebaseAuth.instance.currentUser!.uid;
String? chosenAge;
String? chosenCountry;
String? chosenGender;
String fcmServerToken =
    "key=AAAAHvfaXZk:APA91bH4NX4igHHI881FG-deB5K2zaRNrOgZXaa0RIDgItUEIJgl72e7EO2ir6L2ZGsl_KcCIs6iBfuuEXtYecOQAh0f4WcLA86pnn4s-kmZcvV99QoQ-vD3MQ44tOILY9LLJU2QOrR-";
