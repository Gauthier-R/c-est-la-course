
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String currentGroupId; // Current group being viewed
  final List<String> groupIds; // All groups the user is a part of
  final String? photoBase64; // User's profile picture as Base64 string

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.currentGroupId,
    required this.groupIds,
    this.photoBase64,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      currentGroupId: data['currentGroupId'] ?? '',
      groupIds: List<String>.from(data['groupIds'] ?? []),
      photoBase64: data['photoBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'currentGroupId': currentGroupId,
      'groupIds': groupIds,
      if (photoBase64 != null) 'photoBase64': photoBase64,
    };
  }
}
