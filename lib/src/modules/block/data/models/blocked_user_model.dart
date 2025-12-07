import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/blocked_user_entity.dart';

part 'blocked_user_model.freezed.dart';
part 'blocked_user_model.g.dart';

@freezed
class BlockedUserModel with _$BlockedUserModel {
  const BlockedUserModel._();

  const factory BlockedUserModel({
    @JsonKey(name: 'blocked_id') required String userId,
    @JsonKey(name: 'blocked_username') required String username,
    @JsonKey(name: 'blocked_avatar') String? avatarUrl,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _BlockedUserModel;

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserModelFromJson(json);

  BlockedUserEntity toEntity() {
    return BlockedUserEntity(
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
