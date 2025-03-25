import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  //personal info
  String? uid;
  String? imageProfile;
  String? email;
  String? password;
  String? name;
  int? age;
  String? gender;

  String? city;
  String? country;

  int? publishedDateTime;

  //Appearance
  String? height;
  String? weight;

  //Life style
  String? drink;
  String? smoke;
  String? martialStatus;

  String? profession;

  String? livingSituation;

  //Background - Culturel values

  String? education;

  String? religion;
  String? ethnicity;

  Person({
    //personal info
    this.uid,
    this.imageProfile,
    this.email,
    this.password,
    this.name,
    this.age,
    this.gender,
    this.city,
    this.country,
    this.publishedDateTime,
    //appearance
    this.height,
    this.weight,

    //lifestyle
    this.drink,
    this.smoke,
    this.martialStatus,
    this.profession,
    this.livingSituation,

    //Background - Culturel values

    this.education,
    this.religion,
    this.ethnicity,
  });

  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(
      //personal info
      uid: dataSnapshot["uid"],
      name: dataSnapshot["name"],
      imageProfile: dataSnapshot["imageProfile"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      age: dataSnapshot["age"],
      gender: dataSnapshot["gender"],

      city: dataSnapshot["city"],
      country: dataSnapshot["country"],

      publishedDateTime: dataSnapshot["publishedDateTime"],
      //Appearance
      height: dataSnapshot["height"],
      weight: dataSnapshot["weight"],

      //lifestyle
      drink: dataSnapshot["drink"],
      smoke: dataSnapshot["smoke"],
      martialStatus: dataSnapshot["martialStatus"],

      profession: dataSnapshot["profession"],

      livingSituation: dataSnapshot["livingSituation"],

      //background-cultural values

      education: dataSnapshot["education"],

      religion: dataSnapshot["religion"],
      ethnicity: dataSnapshot["ethnicity"],
    );
  }

  Map<String, dynamic> toJson() => {
        //personal info
        "uid": uid,
        "imageProfile": imageProfile,
        "email": email,
        "password": password,
        "name": name,
        "age": age,
        "gender": gender,

        "city": city,
        "country": country,

        "publishedDateTime": publishedDateTime,
        //Appearance
        "height": height,
        "weight": weight,

        //lifestyle
        "drink": drink,
        "smoke": smoke,
        "martialStatus": martialStatus,

        "profession": profession,

        "livingSituation": livingSituation,

        //background-cultural values

        "education": education,

        "religion": religion,
        "ethnicity": ethnicity,
      };
}
