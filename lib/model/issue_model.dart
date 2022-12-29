import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel {
  final String id;
  final String projectId;
  final String status;
  final String assignedTo;
  final String priority;
  final List<String> labels;
  final DateTime created;
  final DateTime due;
  DateTime? completed;
  List<String> attachments;
  final String title;
  final String description;

//<editor-fold desc="Data Methods">

  IssueModel({
    required this.id,
    required this.projectId,
    required this.status,
    required this.assignedTo,
    required this.priority,
    required this.labels,
    required this.created,
    required this.due,
    this.completed,
    required this.attachments,
    required this.title,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectId == other.projectId &&
          status == other.status &&
          assignedTo == other.assignedTo &&
          priority == other.priority &&
          labels == other.labels &&
          created == other.created &&
          due == other.due &&
          completed == other.completed &&
          attachments == other.attachments &&
          title == other.title &&
          description == other.description);

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      status.hashCode ^
      assignedTo.hashCode ^
      priority.hashCode ^
      labels.hashCode ^
      created.hashCode ^
      due.hashCode ^
      completed.hashCode ^
      attachments.hashCode ^
      title.hashCode ^
      description.hashCode;

  @override
  String toString() {
    return 'IssueModel{ id: $id, projectId: $projectId, status: $status, assignedTo: $assignedTo, priority: $priority, labels: $labels, created: $created, due: $due, completed: $completed, attachments: $attachments, title: $title, description: $description,}';
  }

  IssueModel copyWith({
    String? id,
    String? projectId,
    String? status,
    String? assignedTo,
    String? priority,
    List<String>? labels,
    DateTime? created,
    DateTime? due,
    DateTime? completed,
    List<String>? attachments,
    String? title,
    String? description,
  }) {
    return IssueModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      created: created ?? this.created,
      due: due ?? this.due,
      completed: completed ?? this.completed,
      attachments: attachments ?? this.attachments,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'status': status,
      'assignedTo': assignedTo,
      'priority': priority,
      'labels': labels,
      'created': created,
      'due': due,
      'completed': completed,
      'attachments': attachments,
      'title': title,
      'description': description,
    };
  }

  factory IssueModel.fromMap(Map<String, dynamic> map) {
    return IssueModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      status: map['status'] as String,
      assignedTo: map['assignedTo'] as String,
      priority: map['priority'] as String,
      labels: List<String>.from(map["labels"]),
      created: (map['created'] as Timestamp).toDate(),
      due: (map['due'] as Timestamp).toDate(),
      completed: map["completed"] != null
          ? (map['completed'] as Timestamp).toDate()
          : null,
      attachments: List<String>.from(map["attachments"]),
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

//</editor-fold>
}
