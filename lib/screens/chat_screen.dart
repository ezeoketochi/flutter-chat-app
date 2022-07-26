import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  TextEditingController textEditingController = TextEditingController();

  late User loginUser;
  final _firestore = FirebaseFirestore.instance;
  String messageText = "";

  void getCurrentUser() async {
    try {
      final cUser = _auth.currentUser;
      if (cUser != null) {
        loginUser = cUser;
      }
    } catch (e) {
      debugPrint(
        e.toString(),
      );
    }
  }

  void getMessages() async {
    final messages = await _firestore.collection("messages").get();
    for (final message in messages.docs) {
      debugPrint(
        message.data().toString(),
      );
    }
  }

  void messagesStream() async {
    await for (final snapshot
        in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        debugPrint(
          message.data().toString(),
        );
      }
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              messagesStream();
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection("messages")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      snapshots) {
                if (!snapshots.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                final messages = snapshots.data!.docs;
                final currentUser = _auth.currentUser?.email;
                List<MessageBubble> textWidgets = [];
                for (var message in messages) {
                  final messageText = message.data()["text"];
                  final messageSender = message.data()["sender"];
                  MessageBubble textWidget = MessageBubble(
                    sender: messageSender ?? "no name",
                    text: messageText,
                    isUser: currentUser == messageSender,
                  );
                  textWidgets.add(textWidget);
                }

                ListView columnman = ListView(
                  reverse: true,
                  children: textWidgets,
                );
                return Expanded(
                  child: SizedBox(child: columnman),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      controller: textEditingController,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _firestore.collection("messages").add({
                        "text": messageText,
                        "sender": loginUser.email,
                        "timestamp": Timestamp.now(),
                      });
                      textEditingController.clear();
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  final String sender;
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontSize: 12),
          ),
          Material(
            color: isUser ? Colors.blue : Colors.white,
            borderRadius: isUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )
                : const BorderRadius.only(
                    // topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
