import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/user_model.dart';

class Vertex {
  String userID;

  Vertex({required this.userID});
}

class Edge {
  UserModel user1;
  UserModel user2;
  int weight;

  Edge({required this.user1, required this.user2, required this.weight});
}

class CostFactor {
  String interests;
  int score;

  CostFactor({required this.interests, required this.score});
}

class Message {
  String messageContent;
  Timestamp time;
  String sender;
  String receiver;

  Message(
      {required this.messageContent,
      required this.time,
      required this.receiver,
      required this.sender});

  // Message.fromDocumentSnapshot(DocumentSnapshot snapshot) {
  //   Object? Function() data = snapshot.data;
  //   messageContent = data["message-content"];
  //   time = data["time"];
  //   receiver = data["receiver"];
  //   sender = data["sender"];
  // }

  toMap() {
    return {
      "message-content": messageContent,
      "time": time,
      "receiver": receiver,
      "sender": sender,
    };
  }
}
