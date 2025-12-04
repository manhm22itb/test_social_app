class SearchUser {
  final String username;
  final String handle;
  final bool isVerified;
  final String followers;

  const SearchUser({
    required this.username,
    required this.handle,
    required this.isVerified,
    required this.followers,
  });
}