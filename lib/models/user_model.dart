
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String currentGroupId; // Current group being viewed
  final List<String> groupIds; // All groups the user is a part of
  final String? photoBase64; // User's profile picture as Base64 string
  final String? primaryGroupId; // Default group created at account creation (cannot be deleted)

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.currentGroupId,
    required this.groupIds,
    this.photoBase64,
    this.primaryGroupId,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    final groupIds = List<String>.from(data['groupIds'] ?? []);
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      currentGroupId: data['currentGroupId'] ?? '',
      groupIds: groupIds,
      photoBase64: data['photoBase64'],
      // Fallback : si le champ n'existe pas encore, on utilise le premier groupe de la liste
      primaryGroupId: data['primaryGroupId'] as String? ?? (groupIds.isNotEmpty ? groupIds.first : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'currentGroupId': currentGroupId,
      'groupIds': groupIds,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      if (primaryGroupId != null) 'primaryGroupId': primaryGroupId,
    };
  }
}
