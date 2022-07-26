import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// void findMatch(){
//   // await fina
// }

// this returns the list of all users
Future<List> getAllUsers() async {
  List users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  await _firestore.collection('users').get().then(
    (value) {
      users = value.docs;
    },
  );
  return users;
}

// make vertex from user
List<Vertex> getVertex(List<UserModel> usermodels) {
  List<Vertex> vertexList = [];
  for (UserModel i in usermodels) {
    vertexList.add(Vertex(userID: i.uid));
  }
  return vertexList;
}

// this makes all possible Edges from a users list
List<Edge> getEdge(List<UserModel> usermodels) {
  List<Edge> edgeList = [];

  for (int i = 0; i < usermodels.length - 1; i++) {
    for (int j = i + 1; j < usermodels.length; j++) {
      edgeList.add(Edge(user1: usermodels[i], user2: usermodels[j], weight: 0));
    }
  }
  return edgeList;
}

int getEngagementOfUser(UserModel user) {
  return 10;
}

int getContributionOfUser(UserModel user) {
  return 1;
}

// defining cost factor
void defineCostFactor(List<UserModel> usermodels) {
  for (UserModel i in usermodels) {
    for (String s in i.interest) {
      int engagement = getEngagementOfUser(i);
      int contribution = getContributionOfUser(i);

      int score = contribution * 10 + engagement * 3;
      CostFactor costFactor = CostFactor(interests: s, score: score);
      i.costFactor = {costFactor.interests: costFactor.score.toString()};
    }
  }
}

// findSameInterest(user1, user2){
// 	list1 = user1.interest
// 	list2 = user2.interest

// 	commonContent = findCommon(list1, list2)
// 	return commonContent;
// }

List<String> findSimilarInterest(UserModel user1, UserModel user2) {
  List<String> user1Interest = user1.interest;
  List<String> user2Interest = user2.interest;

  List<String> commonInterest = [];
  for (String s in user1Interest) {
    if (user2Interest.contains(s)) {
      commonInterest.add(s);
    }
  }
  return commonInterest;
}

// defining edge weight
void defineEdgeWeight(List<Edge> edges) {
  int edgeWeight = 0;
  List<int> interstCostFactorDifferenceList = [];
  for (Edge i in edges) {
    List<String> commonIntrest = findSimilarInterest(i.user1, i.user2);
    if (commonIntrest.isNotEmpty) {
      for (String j in commonIntrest) {
        int? costfactor1 = int.parse(i.user1.costFactor![i]!);
        int? costfactor2 = int.parse(i.user2.costFactor![i]!);

        interstCostFactorDifferenceList.add(costfactor1 - costfactor2);
      }
    }
    for (int i in interstCostFactorDifferenceList) {
      edgeWeight += i;
    }
    i.weight = edgeWeight;
  }
}

// finding match
// findMatch(List of weighted edge only of the current user){
// 	find the min value of the list to find ORDINARY
// 	find the max value of the list to find SUPIOR
// }
UserModel findMatch(List<Edge> allEdgeList) {
  // TODO: Get current user
  UserModel currentUser = UserModel(
    name: "Sohail",
    department: "CSE",
    photoUrl: "photoUrl",
    batch: "2019",
    email: "sohail213...",
    randomID: 534534534534,
    about: "about",
    isMatched: false,
    uid: "23342342",
    currentMatch: "currentMatch",
    chatRoomID: "chatRoomID",
    interest: ["interest"],
    costFactor: {"Cars": "3"},
  );

  List<Edge> usersEdgeList = [];
  for (Edge i in allEdgeList) {
    if (i.user1 == currentUser || i.user2 == currentUser) {
      usersEdgeList.add(i);
    }
  }

  // TODO: find the least weight from this edge list.
  // and return the user
  return currentUser;
}
