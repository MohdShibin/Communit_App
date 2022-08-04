class UserModel {
  String uid;
  String email;
  Map<String, dynamic> interest;
  Map<String, int>? costFactor;
  int? tempCostFactor;

  UserModel({
    required this.email,
    required this.uid,
    required this.interest,
    this.costFactor,
    this.tempCostFactor,
  });

  // using factory to create an instance of UserModel
  factory UserModel.fromMap(Map data) {
    return UserModel(
      email: data['email'],
      uid: data['uid'],
      interest: data['interest'],
    );
  }
}
