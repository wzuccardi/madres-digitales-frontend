class PermissionRole {

  PermissionRole({
    required this.id,
    required this.rolId,
    required this.permissionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PermissionRole.fromJson(Map<String, dynamic> json) {
    return PermissionRole(
      id: json['id'] ?? '',
      rolId: json['rolId'] ?? '',
      permissionId: json['permissionId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final String rolId;
  final String permissionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rolId': rolId,
      'permissionId': permissionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PermissionRole copyWith({
    String? id,
    String? rolId,
    String? permissionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PermissionRole(
      id: id ?? this.id,
      rolId: rolId ?? this.rolId,
      permissionId: permissionId ?? this.permissionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionRole &&
        other.id == id &&
        other.rolId == rolId &&
        other.permissionId == permissionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ rolId.hashCode ^ permissionId.hashCode;
  }

  @override
  String toString() {
    return 'PermissionRole(id: $id, rolId: $rolId, permissionId: $permissionId)';
  }
}