class ProjectModel {
  final String title;
  final String description;
  final String projectPic;
  final List<String> owners;
  final List<String> members;
  final String id;

//<editor-fold desc="Data Methods">

  const ProjectModel({
    required this.title,
    required this.description,
    required this.projectPic,
    required this.owners,
    required this.members,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectModel &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          projectPic == other.projectPic &&
          owners == other.owners &&
          members == other.members &&
          id == other.id);

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      projectPic.hashCode ^
      owners.hashCode ^
      members.hashCode ^
      id.hashCode;

  @override
  String toString() {
    return 'ProjectModel{ title: $title, description: $description, projectPic: $projectPic, owners: $owners, members: $members, id: $id,}';
  }

  ProjectModel copyWith({
    String? title,
    String? description,
    String? projectPic,
    List<String>? owners,
    List<String>? members,
    String? id,
  }) {
    return ProjectModel(
      title: title ?? this.title,
      description: description ?? this.description,
      projectPic: projectPic ?? this.projectPic,
      owners: owners ?? this.owners,
      members: members ?? this.members,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'projectPic': projectPic,
      'owners': owners,
      'members': members,
      'id': id,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      title: map['title'] as String,
      description: map['description'] as String,
      projectPic: map['projectPic'] as String,
      owners: List<String>.from(map["owners"]),
      members: List<String>.from(map["members"]),
      id: map['id'] as String,
    );
  }

//</editor-fold>
}
