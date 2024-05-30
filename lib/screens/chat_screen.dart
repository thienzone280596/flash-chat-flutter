
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //todo variable
  final messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;


  late String messageText;
  //Todo get current user
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        // print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }
//todo get messages
//   void getMessages() async {
//     final messages = await _firestore.collection('messages').get();
//     for (var message in messages.docs) {
//       print('Data: ${message.data()}');
//     }
//   }
//todo messages stream
  void getMessageStream() async {
    await for(var _snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in _snapshot.docs) {
       print('Data: ${message.data()}');
    }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                getMessageStream();
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //xoadat
                      messageController.clear();
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
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

//todo Message Stream
class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return   StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          late final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            Map<String, dynamic> data = message.data()! as Map<String, dynamic>;
            final messageText = data['text'];
            final messageSender = data['sender'];
            final currentUser = loggedInUser.email;
            if (currentUser == messageSender) {

            }
            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe:  currentUser == messageSender,);
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal:10),
              children: messageBubbles,
            ),
          );
        }
    );
  }
}

//Todo message Bubble
class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(
            fontSize: 12,
            color: Colors.black54
          ),),
          Material(
            borderRadius:isMe ? BorderRadius.only(topLeft: Radius.circular(30.0),
                bottomLeft:Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)):
            BorderRadius.only(topRight: Radius.circular(30.0),
                bottomLeft:Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(text,
                style: TextStyle(
                    fontSize: 15,
                    color: isMe ? Colors.white: Colors.black54),
              ),
            ),
          ),
        ]
      ),
    );
  }
}