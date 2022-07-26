class UserModel {
  String uid;
  String email;
  String batch;
  String department;
  String name;
  String photoUrl;
  int randomID;
  String about;
  bool isMatched;
  String currentMatch;
  String chatRoomID;
  List<String> interest;
  Map<String, String>? costFactor;

  UserModel({
    required this.name,
    required this.department,
    required this.photoUrl,
    required this.batch,
    required this.email,
    required this.randomID,
    required this.about,
    required this.isMatched,
    required this.uid,
    required this.currentMatch,
    required this.chatRoomID,
    required this.interest,
    required this.costFactor,
  });
}
