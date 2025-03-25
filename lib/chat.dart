import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/AppLocalizations.dart';
import 'package:dating_app/homeScreen/home_screen.dart';
import 'package:dating_app/tabScreens/messages.dart';
import 'package:dating_app/tabScreens/user_details_screen.dart';
import 'package:dating_app/widgets/custom_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:rxdart/rxdart.dart';

class Chat extends StatefulWidget {
  final String profileImage; // Profil resmi için değişken
  final String profileName; // Profil adı için değişken
  final String profileUserId; // Kullanıcının benzersiz ID'si

  const Chat({
    super.key,
    required this.profileImage,
    required this.profileName,
    required this.profileUserId,
  });

  @override
  State<Chat> createState() => _ChatState();
}

// ... (Diğer kodlarınız)

class _ChatState extends State<Chat> {
  TextEditingController chatTextEditingController = TextEditingController();
  List<Message> messages = []; // Mesaj listesi
  late DateTime lastMessageTime;
  @override
  void initState() {
    super.initState();
    lastMessageTime = DateTime.now();
    getMessagesStream(); // Sayfa yüklendiğinde mesajları yükle
    listenForOtherMessages();
  }

  void showTopSnackBar(BuildContext context, String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20.0,
        right: 0.0,
        left: 0.0,
        child: Material(
          elevation: 10.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 60,
            color: Colors.blue,
            child: InkWell(
              onTap: () {
                // Burada istediğiniz sayfaya yönlendirme yapabilirsiniz
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const Messages()), // Yeni sayfa
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    // Otomatik olarak gizlemek için gecikme süresi
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void listenForOtherMessages() {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messages")
        .snapshots()
        .listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var messageData = change.doc.data();
            var senderId = messageData?["senderId"];
            var timestamp =
                (messageData?["timestamp"] as Timestamp?)?.toDate() ??
                    DateTime.now();

            if (senderId != currentUserID &&
                senderId != widget.profileUserId &&
                timestamp.isAfter(lastMessageTime)) {
              // showTopSnackBar fonksiyonunu çağırarak bildirim göster
              showTopSnackBar(
                  context,
                  AppLocalizations.of(Get.context!)!
                      .translate("You have a new message.Click here!"));
            }
          }
        }
      },
    );
  }

  Stream<List<Message>> getMessagesStream() {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;
    var userMessagesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messages")
        .where('senderId', isEqualTo: widget.profileUserId);

    var otherUserMessagesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.profileUserId)
        .collection("messages")
        .where('senderId', isEqualTo: currentUserID);

    // İki stream'i birleştiren bir stream döndür
    return Rx.combineLatest2(
        userMessagesRef.snapshots(), otherUserMessagesRef.snapshots(),
        (QuerySnapshot userSnapshot, QuerySnapshot otherUserSnapshot) {
      var messages = <Message>[];
      messages
          .addAll(userSnapshot.docs.map((doc) => Message.fromSnapshot(doc)));
      messages.addAll(
          otherUserSnapshot.docs.map((doc) => Message.fromSnapshot(doc)));
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  sendMessage(String toUserID, String message) async {
    var currentUserID =
        FirebaseAuth.instance.currentUser!.uid; // Mevcut kullanıcı ID

    /// Alıcıya mesaj gönder
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.profileUserId) // Hedef kullanıcının ID'si
        .collection("messages")
        .doc()
        .set({
      // Yeni bir mesaj belgesi oluştur
      'message': message,
      'receiverId': widget.profileUserId,
      'senderId': currentUserID,
      'timestamp': FieldValue.serverTimestamp(), // Mesajın gönderildiği zaman
    });

    // Göndericiye aynı mesajı kaydet
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messages")
        .doc()
        .set({
      'message': message,
      'receiverId': widget.profileUserId,
      'senderId': currentUserID,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Get.to(const HomeScreen());
                },
                icon: const Icon(Icons.arrow_back)),
            InkWell(
              onTap: () {
                Get.to(UserDetailsScreen(userID: widget.profileUserId));
              },
              child: CircleAvatar(
                radius: 27,
                backgroundImage:
                    NetworkImage(widget.profileImage, scale: 1), // Profil resmi
              ),
            ),
            const SizedBox(width: 10), // Boşluk
            Text(
              widget.profileName,
              // Profil adı
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: getMessagesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var messages = snapshot.data!;

              return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message.senderId ==
                        FirebaseAuth.instance.currentUser!.uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextFieldWidget(
                editingController: chatTextEditingController,
                labelText: AppLocalizations.of(context)!.translate("Chat"),
                iconData: Icons.chat,
                isObscure: false,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {
                if (chatTextEditingController.text.isNotEmpty) {
                  sendMessage(
                      widget.profileName, chatTextEditingController.text);
                  chatTextEditingController
                      .clear(); // Mesaj gönderildikten sonra alanı temizle
                  // Klavyeyi kapat
                  FocusScope.of(context).unfocus();
                }
              },
              child: Text(
                AppLocalizations.of(context)!.translate("Send"),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      const Size(50, 59)), // Butonun genişliği ve yüksekliği
                  backgroundColor: MaterialStateProperty.all(Colors.white)),
            ),
          ],
        ),
      ]),
    );
  }
}

class Message {
  late String text;
  late String senderId;
  late String receiverId;
  late DateTime timestamp;

  Message.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;

    text = data?.containsKey('message') ?? false ? data!['message'] : '';
    senderId = data?.containsKey('senderId') ?? false ? data!['senderId'] : '';
    receiverId =
        data?.containsKey('receiverId') ?? false ? data!['receiverId'] : '';
    timestamp = data?.containsKey('timestamp') ?? false
        ? (data!['timestamp'] as Timestamp).toDate()
        : DateTime.now(); // Eğer timestamp yoksa şu anki zamanı kullan
  }
}
