import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserModel> mainMatch() async {
  // get all users
  List<UserModel> allUsers = await getAllUsers();
  // make users as vertex of graph
  List<Vertex> vertex = getVertex(allUsers);
  // define cost factor for each user
  allUsers = await defineCostFactor(allUsers);
  // find users with similar interest
  List<UserModel> similarInterestUsers =
      await findSimilarInterestUsers(allUsers);
  print("Similar interest users ---------------------");
  print(similarInterestUsers);
  // get all possible edges with this user list
  List<Edge> edges = getEdge(similarInterestUsers);
  // finding weight for each edge
  defineEdgeWeight(edges);
  UserModel matchedUser = findMatch(edges);
  print("Matched user ------------------------------=");
  print(matchedUser.uid);
  return matchedUser;
}

UserModel findMatch(List<Edge> allEdgeList) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;

  List<Edge> usersEdgeList = [];
  for (Edge i in allEdgeList) {
    if (i.user1.uid == currentUser!.uid || i.user2.uid == currentUser.uid) {
      usersEdgeList.add(i);
    }
  }
  final random = Random();

  Edge selectedEdgeSimilar = usersEdgeList.first;
  // usersEdgeList[random.nextInt(usersEdgeList.length)];

  // Edge selectedEdgeSuperior = usersEdgeList
  // usersEdgeList[random.nextInt(usersEdgeList.length)];

  int min = 0;
  int max = 9999;
  for (Edge e in usersEdgeList) {
    if (e.weight < min) {
      min = e.weight;
      selectedEdgeSimilar = e;
    }
    if (e.weight > max) {
      max = e.weight;
      // selectedEdgeSuperior = e;
    }
  }
  if (selectedEdgeSimilar.user1 == currentUser) {
    return selectedEdgeSimilar.user2;
  } else {
    return selectedEdgeSimilar.user1;
  }
}

// this returns the list of all users
Future<List<UserModel>> getAllUsers() async {
  print("Get all user data working----------------\n\n");
  List<UserModel> users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final querySnapshot = await _firestore.collection('users').get();

  for (var i in querySnapshot.docs) {
    users.add(UserModel.fromMap(i.data()));
    print(i.data());
  }

  return users;
}

//get current userModel
// this returns the list of all users
Future<UserModel> getCurrentUser() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  print("Get current user data working----------------\n\n");

  final doc = await _firestore.collection('users').doc(currentUser?.uid).get();

  UserModel user = UserModel(
      email: doc['email'], uid: doc['uid'], interest: doc['interest']);

  return user;
}

// make vertex from user
List<Vertex> getVertex(List<UserModel> usermodels) {
  List<Vertex> vertexList = [];
  for (UserModel i in usermodels) {
    vertexList.add(Vertex(userID: i.uid));
  }
  print("Returning vertex list.....\n\n");
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

// defining cost factor
Future<List<UserModel>> defineCostFactor(List<UserModel> usermodels) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  for (var u in usermodels) {
    print("user interest " + u.interest.toString());
    u.interest.forEach((intere, value) {
      int engagement = value['engagement'];
      print("engagement = " + engagement.toString());
      int contribution = value['contribution'];
      print("contribution = " + contribution.toString());

      int score = contribution * 10 + engagement * 3;
      print("Score = " + score.toString());

      u.costFactor?.putIfAbsent(intere, () => score);
      if (u.tempCostFactor == null) {
        u.tempCostFactor = score;
      } else if (u.tempCostFactor != null) {
        u.tempCostFactor = u.tempCostFactor! + score;
      }
      // u.costFactor?.addAll({intere: score});
      // u.costFactor?.update(
      //   intere,
      //   (value) => score,
      //   ifAbsent: () => score,
      // );
      print("\n\n\n\n");
      print("cost factor = " + u.costFactor.toString());
      print("temp cost factor = " + u.tempCostFactor.toString());
    });
  }
  return usermodels;
  // var user =
  //     await _firestore.collection('users').doc(usermodels.uid).get();

  // Map<String, Map<String, int>> interest = user.get("interest");
  // print(interest);

  // for (User i in usermodels) {
  //   for (String s in i.interest) {
  //     int engagement = getEngagementOfUser(i);
  //     int contribution = getContributionOfUser(i);

  //     int score = contribution * 10 + engagement * 3;
  //     CostFactor costFactor = CostFactor(interests: s, score: score);
  //     i.costFactor = {costFactor.interests: costFactor.score.toString()};
  //   }
  // }
}

// get users of similar interest
Future<List<UserModel>> findSimilarInterestUsers(
    List<UserModel> userModels) async {
  List<UserModel> similarInterestUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;
  UserModel currentUserModel = await getCurrentUser();
  for (int i = 0; i < userModels.length - 1; i++) {
    if (isSimilarInterest(currentUserModel, userModels[i])) {
      similarInterestUsers.add(userModels[i]);
    }
  }
  return similarInterestUsers;
}

// returns true if similar interest is present
bool isSimilarInterest(UserModel user1, UserModel user2) {
  int hasCommon = 0;
  user1.interest.forEach((key, value) {
    if (user2.interest.containsKey(key)) {
      hasCommon++;
    }
  });
  if (hasCommon > 0) {
    return true;
  } else {
    return false;
  }
}

// defining edge weight
void defineEdgeWeight(List<Edge> edges) {
  int edgeWeight = 0;
  List<int> interstCostFactorDifferenceList = [];
  for (Edge i in edges) {
    // List<String> commonIntrest = findSimilarInterest(i.user1, i.user2);
    // if (commonIntrest.isNotEmpty) {
    // for (String j in commonIntrest) {
    int? costfactor1 = i.user1.tempCostFactor;
    int? costfactor2 = i.user2.tempCostFactor;

    interstCostFactorDifferenceList.add(costfactor1! - costfactor2!);
    // }
    // }
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
