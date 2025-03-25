import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  var currentUserID = FirebaseAuth.instance.currentUser!.uid;
  Stream<QuerySnapshot>? messagesStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Sayfaya her geri dönüşte çalışacak kodlar
          messagesStream = FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserID)
              .collection("messages")
              .orderBy('timestamp', descending: true)
              .snapshots();
        });
      }
    });
  }

  Future<Map<String, dynamic>?> _getLastMessage(String otherUserId) async {
    // Gelen mesajları al
    var receivedMessages = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messages")
        .where('senderId', isEqualTo: otherUserId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    // Giden mesajları al
    var sentMessages = await FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserId)
        .collection("messages")
        .where('senderId', isEqualTo: currentUserID)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    print(
        "Sent messages: ${sentMessages.docs.length}"); // This line will print the count of sent messages

    if (receivedMessages.docs.isNotEmpty && sentMessages.docs.isNotEmpty) {
      // En son gelen ve giden mesajları karşılaştır
      var lastReceivedMessage = receivedMessages.docs.first;
      var lastSentMessage = sentMessages.docs.first;
      return lastReceivedMessage['timestamp']
                  .compareTo(lastSentMessage['timestamp']) >
              0
          ? lastReceivedMessage.data()
          : lastSentMessage.data();
    } else if (receivedMessages.docs.isNotEmpty) {
      return receivedMessages.docs.first.data();
    } else if (sentMessages.docs.isNotEmpty) {
      return sentMessages.docs.first.data();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // messagesStream null kontrolü
    if (messagesStream == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Mesajlar"),
          centerTitle: true,
        ),
        body:
            Center(child: CircularProgressIndicator()), // Yükleme gösteriliyor
      );
    }
    // messagesStream null değilse, normal UI render ediliyor
    return Scaffold(
      appBar: AppBar(
        title: Text("Mesajlar"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Mesaj Yok"));
          }

          // Kullanıcı mesajlarını grupla
          var messageGroups = <String, Map<String, dynamic>>{};
          for (var doc in snapshot.data!.docs) {
            var message = doc.data() as Map<String, dynamic>;
            var otherUserId = message['senderId'] == currentUserID
                ? message['receiverId']
                : message['senderId'];
            if (!messageGroups.containsKey(otherUserId)) {
              messageGroups[otherUserId] = message;
            }
          }

          var userIds = messageGroups.keys.toList();

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              var userId = userIds[index];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getLastMessage(userId),
                builder: (context, lastMessageSnapshot) {
                  if (lastMessageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                        leading: CircleAvatar(), title: Text("Yükleniyor..."));
                  }

                  var lastMessage = lastMessageSnapshot.data;
                  if (lastMessage == null) {
                    return ListTile(
                        leading: CircleAvatar(), title: Text("Mesaj yok"));
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(userId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                            leading: CircleAvatar(),
                            title: Text(lastMessage['message']));
                      }

                      if (!userSnapshot.hasData ||
                          userSnapshot.data?.data() == null) {
                        return ListTile(
                            leading: CircleAvatar(),
                            title: Text(lastMessage['message']));
                      }

                      var userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      String profilePicUrl = userData['imageProfile'] ?? '';
                      String userName = userData['name'] ?? 'Unknown User';
                      String uid = userData['uid'] ?? '';

                      return InkWell(
                        onTap: () {
                          Get.to(Chat(
                              profileImage: profilePicUrl,
                              profileName: userName,
                              profileUserId: uid));
                        },
                        child: ListTile(
                            leading: _buildAvatar(profilePicUrl),
                            title: Container(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: userName + ":  ",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        TextSpan(
                                          text: lastMessage['message'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            )),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String imageUrl) {
    return ClipOval(
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 40.0, // İstediğiniz boyut
              height: 40.0,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child; // Resim yüklendi
                return CircularProgressIndicator(); // Resim yüklenirken
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Icon(Icons.account_circle,
                    size: 40.0); // Hata oluştuğunda varsayılan ikon
              },
            )
          : Icon(Icons.account_circle,
              size: 40.0), // Resim URL'si boşsa varsayılan ikon
    );
  }
}
