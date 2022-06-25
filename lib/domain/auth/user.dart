import 'package:ddd_reso/domain/core/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required UniqueId id,
  }) = _AppUser;
}