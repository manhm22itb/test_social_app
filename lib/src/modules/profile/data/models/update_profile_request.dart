import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_request.freezed.dart';
part 'update_profile_request.g.dart';

@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? username,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
