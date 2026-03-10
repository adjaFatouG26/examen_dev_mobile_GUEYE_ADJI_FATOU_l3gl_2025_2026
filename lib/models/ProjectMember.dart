enum MemberRole { owner, admin, member }

class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final MemberRole role;
  final DateTime joinedAt;

  // Constructeur

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    this.role = MemberRole.member,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  // Copie champs modifé

  ProjectMember copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    MemberRole? role,
    DateTime? joinedAt,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  // Convertit un map pour la serialisation

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  // créer depuis un map
  factory ProjectMember.fromMap(Map<String, dynamic> map) {
    return ProjectMember(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      role: MemberRole.values.byName(map['role'] as String),
      joinedAt: DateTime.parse(map['joinedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ProjectMember(id: $id, userId: $userId, role: $role)';
  }
}