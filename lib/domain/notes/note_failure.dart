import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_failure.freezed.dart';

@freezed
abstract class NoteFailure with _$NoteFailure {
  const factory NoteFailure.unexpected() = _Unexpected;
  const factory NoteFailure.insufficientPermisssion() = _InsufficientPermisssion;
  const factory NoteFailure.noteNotFound() = _NoteNotFound;
  const factory NoteFailure.unableToUpdate() = _UnableToUpdate;
  const factory NoteFailure.db() = _Database;
}
