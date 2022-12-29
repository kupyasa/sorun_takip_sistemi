class NotificationModel {
  final String id;
  final bool isInformation;
  final bool isProjectInvitation;
  final bool isTeamInvitation;
  final String receiverId;
  final String receiverName;
  final String senderId;
  final String senderName;
  final String projectTeamName;
  final String projectTeamId;
  final String message;

//<editor-fold desc="Data Methods">

  const NotificationModel({
    required this.id,
    required this.isInformation,
    required this.isProjectInvitation,
    required this.isTeamInvitation,
    required this.receiverId,
    required this.receiverName,
    required this.senderId,
    required this.senderName,
    required this.projectTeamName,
    required this.projectTeamId,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isInformation == other.isInformation &&
          isProjectInvitation == other.isProjectInvitation &&
          isTeamInvitation == other.isTeamInvitation &&
          receiverId == other.receiverId &&
          receiverName == other.receiverName &&
          senderId == other.senderId &&
          senderName == other.senderName &&
          projectTeamName == other.projectTeamName &&
          projectTeamId == other.projectTeamId &&
          message == other.message);

  @override
  int get hashCode =>
      id.hashCode ^
      isInformation.hashCode ^
      isProjectInvitation.hashCode ^
      isTeamInvitation.hashCode ^
      receiverId.hashCode ^
      receiverName.hashCode ^
      senderId.hashCode ^
      senderName.hashCode ^
      projectTeamName.hashCode ^
      projectTeamId.hashCode ^
      message.hashCode;

  @override
  String toString() {
    return 'NotificationModel{ id: $id, isInformation: $isInformation, isProjectInvitation: $isProjectInvitation, isTeamInvitation: $isTeamInvitation, receiverId: $receiverId, receiverName: $receiverName, senderId: $senderId, senderName: $senderName, projectTeamName: $projectTeamName, projectTeamId: $projectTeamId, message: $message,}';
  }

  NotificationModel copyWith({
    String? id,
    bool? isInformation,
    bool? isProjectInvitation,
    bool? isTeamInvitation,
    String? receiverId,
    String? receiverName,
    String? senderId,
    String? senderName,
    String? projectTeamName,
    String? projectTeamId,
    String? message,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      isInformation: isInformation ?? this.isInformation,
      isProjectInvitation: isProjectInvitation ?? this.isProjectInvitation,
      isTeamInvitation: isTeamInvitation ?? this.isTeamInvitation,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      projectTeamName: projectTeamName ?? this.projectTeamName,
      projectTeamId: projectTeamId ?? this.projectTeamId,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isInformation': isInformation,
      'isProjectInvitation': isProjectInvitation,
      'isTeamInvitation': isTeamInvitation,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'senderId': senderId,
      'senderName': senderName,
      'projectTeamName': projectTeamName,
      'projectTeamId': projectTeamId,
      'message': message,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      isInformation: map['isInformation'] as bool,
      isProjectInvitation: map['isProjectInvitation'] as bool,
      isTeamInvitation: map['isTeamInvitation'] as bool,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      projectTeamName: map['projectTeamName'] as String,
      projectTeamId: map['projectTeamId'] as String,
      message: map['message'] as String,
    );
  }
//</editor-fold>
}
