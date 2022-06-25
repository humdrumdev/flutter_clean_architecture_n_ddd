import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddd_reso/domain/core/value_objects.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/domain/notes/todo_item.dart';
import 'package:ddd_reso/domain/notes/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/kt.dart';

part 'notes_dtos.freezed.dart';
part 'notes_dtos.g.dart';


@freezed
abstract class NoteDto implements _$NoteDto {
  const NoteDto._();

  const factory NoteDto({
    @JsonKey(ignore: true) String? id,
    required String body,
    required int color,
    required List<TodoItemDto> todos,
    @ServerTimestampConverter() required FieldValue serverTimestamp,
  }) = _NoteDto;

  factory NoteDto.fromDomain(Note note) {
    return NoteDto(
      id: note.id.getOrCrash(),
      body: note.body.getOrCrash(),
      color: note.color.getOrCrash().value,
      todos: note.todos
      .getOrCrash()
      .map((todoItem) => TodoItemDto.fromDomain(todoItem))
      .asList(),
      serverTimestamp: FieldValue.serverTimestamp(),
    );
  }
  Note toDomain() {
    return Note(
      id: UniqueId.fromUniqueString(id!),
      body: NoteBody(body),
      color: NoteColor(Color(color)),
      todos: List3(todos.map((todoItem) => todoItem.toDomain()).toImmutableList()),
    );
  }

  factory NoteDto.fromJson(Map<String, dynamic> json) => _$NoteDtoFromJson(json);

  factory NoteDto.fromFirestore(DocumentSnapshot doc) {
    return NoteDto.fromJson(doc.data() as Map<String, dynamic>).copyWith(id: doc.id);
  }
}


class ServerTimestampConverter implements JsonConverter<FieldValue, Object> {
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object toJson(FieldValue fieldValue) {
    return fieldValue;
  }
}

@freezed
abstract class TodoItemDto implements _$TodoItemDto {
  const TodoItemDto._();

  const factory TodoItemDto({
    required String id,
    required String name,
    required bool done,
  }) = _TodoItemDto;

  factory TodoItemDto.fromDomain(TodoItem todoItem) {
    return TodoItemDto(
      id: todoItem.id.getOrCrash(),
      name: todoItem.name.getOrCrash(),
      done: todoItem.done,
    );
  }

  TodoItem toDomain() {
    return TodoItem(
      id: UniqueId.fromUniqueString(id),
      name: TodoName(name),
      done: done,
    );
  }

  factory TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDtoFromJson(json);

}