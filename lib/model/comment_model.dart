import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String projectTeamId;
  final String? issueId;
  final String senderName;
  final String senderId;
  final String message;
  final DateTime created;
  final List<String> attachments;

//<editor-fold desc="Data Methods">

  const CommentModel({
    required this.id,
    required this.projectTeamId,
    this.issueId,
    required this.senderName,
    required this.senderId,
    required this.message,
    required this.created,
    required this.attachments,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectTeamId == other.projectTeamId &&
          issueId == other.issueId &&
          senderName == other.senderName &&
          senderId == other.senderId &&
          message == other.message &&
          created == other.created &&
          attachments == other.attachments);

  @override
  int get hashCode =>
      id.hashCode ^
      projectTeamId.hashCode ^
      issueId.hashCode ^
      senderName.hashCode ^
      senderId.hashCode ^
      message.hashCode ^
      created.hashCode ^
      attachments.hashCode;

  @override
  String toString() {
    return 'CommentModel{ id: $id, projectTeamId: $projectTeamId, issueId: $issueId, senderName: $senderName, senderId: $senderId, message: $message, created: $created, attachments: $attachments,}';
  }

  CommentModel copyWith({
    String? id,
    String? projectTeamId,
    String? issueId,
    String? senderName,
    String? senderId,
    String? message,
    DateTime? created,
    List<String>? attachments,
  }) {
    return CommentModel(
      id: id ?? this.id,
      projectTeamId: projectTeamId ?? this.projectTeamId,
      issueId: issueId ?? this.issueId,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      created: created ?? this.created,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectTeamId': projectTeamId,
      'issueId': issueId,
      'senderName': senderName,
      'senderId': senderId,
      'message': message,
      'created': created,
      'attachments': attachments,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
        id: map['id'] as String,
        projectTeamId: map['projectTeamId'] as String,
        issueId: map['issueId'] != null ? map['issueId'] as String : null,
        senderName: map['senderName'] as String,
        senderId: map['senderId'] as String,
        message: map['message'] as String,
        attachments: List<String>.from(map['attachments']),
        created: (map['created'] as Timestamp).toDate());
  }

//</editor-fold>
}
