import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final String inviteCode;
  final List<String> members;
  final List<String> pendingRequests;
  final int weekStartDay; // 1 = Lundi, ..., 7 = Dimanche

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.inviteCode,
    required this.members,
    required this.pendingRequests,
    this.weekStartDay = 1,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GroupModel(
      id: documentId,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      pendingRequests: List<String>.from(data['pendingRequests'] ?? []),
      weekStartDay: (data['weekStartDay'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'inviteCode': inviteCode,
      'members': members,
      'pendingRequests': pendingRequests,
      'weekStartDay': weekStartDay,
    };
  }
}
