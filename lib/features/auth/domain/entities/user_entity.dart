class UserEntity {
  final String id;
  final String email;
  final String? username;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
  });
}
