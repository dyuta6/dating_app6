import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/global.dart';
import 'package:dating_app/tabScreens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewSentViewReceivedScreen extends StatefulWidget {
  const ViewSentViewReceivedScreen({super.key});

  @override
  State<ViewSentViewReceivedScreen> createState() =>
      _ViewSentViewReceivedScreenState();
}

class _ViewSentViewReceivedScreenState
    extends State<ViewSentViewReceivedScreen> {
  bool isViewSentClicked = true;
  List<String> viewSentList = [];
  List<String> viewReceivedtList = [];
  List viewstList = [];

  getViewsListKeys() async {
    if (isViewSentClicked) {
      var viewSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection("viewSent")
          .get();

      for (int i = 0; i < viewSentDocument.docs.length; i++) {
        viewSentList.add(viewSentDocument.docs[i].id);
      }
      print("viewSentList " + viewSentList.toString());
      getKeysDataFromUsersCollection(viewSentList);
    } else {
      var viewReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection("viewReceived")
          .get();

      for (int i = 0; i < viewReceivedDocument.docs.length; i++) {
        viewReceivedtList.add(viewReceivedDocument.docs[i].id);
      }
      print("viewReceivedtList " + viewReceivedtList.toString());
      getKeysDataFromUsersCollection(viewReceivedtList);
    }
  }

  getKeysDataFromUsersCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)["uid"]) ==
            keysList[k]) {
          viewstList.add(allUsersDocument.docs[i].data());
        }
      }
    }

    setState(() {
      viewstList;
    });

    print("viewstList " + viewstList.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getViewsListKeys();
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
                  viewSentList.clear();
                  viewSentList = [];
                  viewReceivedtList.clear();
                  viewReceivedtList = [];
                  viewstList.clear();
                  viewstList = [];
                  setState(() {
                    isViewSentClicked = true;
                  });
                  getViewsListKeys();
                },
                child: Text(
                  "Profiline Baktıklarım",
                  style: TextStyle(
                    color: isViewSentClicked ? Colors.white : Colors.grey,
                    fontWeight:
                        isViewSentClicked ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                )),
            const Text(
              "   |   ",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
                onPressed: () {
                  viewSentList.clear();
                  viewSentList = [];
                  viewReceivedtList.clear();
                  viewReceivedtList = [];
                  viewstList.clear();
                  viewstList = [];
                  setState(() {
                    isViewSentClicked = false;
                  });
                  getViewsListKeys();
                },
                child: Text(
                  "Benim Profilime Bakanlar",
                  style: TextStyle(
                    color: isViewSentClicked ? Colors.grey : Colors.white,
                    fontWeight:
                        isViewSentClicked ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                  ),
                )),
          ],
        ),
        centerTitle: true,
      ),
      body: viewstList.isEmpty
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
              children: List.generate(viewstList.length, (index) {
                return GridTile(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Card(
                      color: Colors.blue.shade200,
                      child: GestureDetector(
                        //

                        onTap: () {
                          Get.to(UserDetailsScreen(
                            userID: viewstList[index]
                                ['uid'], // kullanıcının ID'si
                          ));
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: NetworkImage(
                              viewstList[index]["imageProfile"],
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
                                    viewstList[index]["name"].toString() +
                                        " - " +
                                        viewstList[index]["age"].toString(),
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
                                          viewstList[index]["city"].toString() +
                                              " , " +
                                              viewstList[index]["country"]
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
