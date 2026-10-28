/// A sub-access (Access Share) user: someone the institute owner lets into
/// the web panel with a limited set of permissions.
class SubAccessUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final List<String> permissions;
  final String status;
  final DateTime? lastLoginAt;

  const SubAccessUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.permissions = const [],
    this.status = 'active',
    this.lastLoginAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory SubAccessUser.fromJson(Map<String, dynamic> json) {
    final raw = json['permissions'];
    return SubAccessUser(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      permissions: raw is List
          ? raw.map((e) => e.toString()).toList()
          : const [],
      status: json['status']?.toString() ?? 'active',
      lastLoginAt: DateTime.tryParse(json['last_login_at']?.toString() ?? ''),
    );
  }

  SubAccessUser copyWith({String? status}) => SubAccessUser(
    id: id,
    name: name,
    email: email,
    phone: phone,
    permissions: permissions,
    status: status ?? this.status,
    lastLoginAt: lastLoginAt,
  );
}

/// One permission the owner can tick, e.g. `fees.edit`.
class SubAccessPermission {
  final String key;
  final String label;
  final String description;

  const SubAccessPermission({
    required this.key,
    required this.label,
    required this.description,
  });
}

/// A titled group of permissions (Student Management, Fees, ...).
class SubAccessPermissionGroup {
  final String key;
  final String label;
  final List<SubAccessPermission> permissions;

  const SubAccessPermissionGroup({
    required this.key,
    required this.label,
    required this.permissions,
  });

  /// Parses the server's `{group: {label, permissions: {key: {label, desc}}}}`
  /// map into an ordered list.
  static List<SubAccessPermissionGroup> listFromJson(dynamic json) {
    if (json is! Map) return const [];
    final groups = <SubAccessPermissionGroup>[];
    json.forEach((groupKey, value) {
      if (value is! Map) return;
      final perms = <SubAccessPermission>[];
      final rawPerms = value['permissions'];
      if (rawPerms is Map) {
        rawPerms.forEach((permKey, info) {
          final map = info is Map ? info : const {};
          perms.add(
            SubAccessPermission(
              key: permKey.toString(),
              label: map['label']?.toString() ?? permKey.toString(),
              description: map['desc']?.toString() ?? '',
            ),
          );
        });
      }
      groups.add(
        SubAccessPermissionGroup(
          key: groupKey.toString(),
          label: value['label']?.toString() ?? groupKey.toString(),
          permissions: perms,
        ),
      );
    });
    return groups;
  }
}
