import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/tabScreens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppLocalizations.dart';

class LikeSentLikeReceivedScreen extends StatefulWidget {
  const LikeSentLikeReceivedScreen({super.key});

  @override
  State<LikeSentLikeReceivedScreen> createState() =>
      _LikeSentLikeReceivedScreenState();
}

class _LikeSentLikeReceivedScreenState
    extends State<LikeSentLikeReceivedScreen> {
  bool isLikeSentClicked = true;
  List<String> likeSentList = [];
  List<String> likeReceivedtList = [];
  List likestList = [];

  getLikedListKeys() async {
    if (isLikeSentClicked) {
      var likeSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection("likeSent")
          .get();

      for (int i = 0; i < likeSentDocument.docs.length; i++) {
        likeSentList.add(likeSentDocument.docs[i].id);
      }
      print("likeSentList " + likeSentList.toString());
      getKeysDataFromUsersCollection(likeSentList);
    } else {
      var likeReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection("likeReceived")
          .get();

      for (int i = 0; i < likeReceivedDocument.docs.length; i++) {
        likeReceivedtList.add(likeReceivedDocument.docs[i].id);
      }
      print("likeReceivedtList " + likeReceivedtList.toString());
      getKeysDataFromUsersCollection(likeReceivedtList);
    }
  }

  getKeysDataFromUsersCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)["uid"]) ==
            keysList[k]) {
          likestList.add(allUsersDocument.docs[i].data());
        }
      }
    }

    setState(() {
      likestList;
    });

    print("likestList " + likestList.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLikedListKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  likeSentList.clear();
                  likeSentList = [];
                  likeReceivedtList.clear();
                  likeReceivedtList = [];
                  likestList.clear();
                  likestList = [];
                  setState(() {
                    isLikeSentClicked = true;
                  });
                  getLikedListKeys();
                },
                child: Text(
                  AppLocalizations.of(context)!.translate("My Likes"),
                  style: TextStyle(
                    color: isLikeSentClicked ? Colors.white : Colors.grey,
                    fontWeight:
                        isLikeSentClicked ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                )),
            const Text(
              "   |   ",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
                onPressed: () {
                  likeSentList.clear();
                  likeSentList = [];
                  likeReceivedtList.clear();
                  likeReceivedtList = [];
                  likestList.clear();
                  likestList = [];
                  setState(() {
                    isLikeSentClicked = false;
                  });
                  getLikedListKeys();
                },
                child: Text(
                  AppLocalizations.of(context)!.translate("Liked Me"),
                  style: TextStyle(
                    color: isLikeSentClicked ? Colors.grey : Colors.white,
                    fontWeight:
                        isLikeSentClicked ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                  ),
                )),
          ],
        ),
        centerTitle: true,
      ),
      body: likestList.isEmpty
          ? const Center(
              child: Icon(
                Icons.person_off_sharp,
                color: Colors.white,
                size: 60,
              ),
            )
          : GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              children: List.generate(likestList.length, (index) {
                return GridTile(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Card(
                      color: Colors.blue.shade200,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(UserDetailsScreen(
                            userID: likestList[index]
                                ['uid'], // kullanıcının ID'si
                          ));
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: NetworkImage(
                              likestList[index]["imageProfile"],
                            ),
                            fit: BoxFit.cover,
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),

                                  //name-age
                                  Text(
                                    likestList[index]["name"].toString() +
                                        " - " +
                                        likestList[index]["age"].toString(),
                                    maxLines: 2,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),

                                  //icon-city-country
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          likestList[index]["city"].toString() +
                                              " , " +
                                              likestList[index]["country"]
                                                  .toString(),
                                          maxLines: 2,
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
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
                  ),
                );
              }),
            ),
    );
  }
}
