class BlockedUserEntity {
  final String userId; 
  final String username; 
  final String? avatarUrl; 
  final DateTime createdAt; 

  BlockedUserEntity({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });
}
