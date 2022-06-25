import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:ddd_reso/domain/core/failures.dart';
import 'package:ddd_reso/domain/core/value_objects.dart';
import 'package:ddd_reso/domain/core/value_transformers.dart';
import 'package:kt_dart/kt.dart';

import '../core/value_validators.dart';

class NoteBody extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  const NoteBody._(this.value);

  static const maxLength = 1000;

  factory NoteBody(String input) {
    return NoteBody._(
      validateMaxStringLength(input, NoteBody.maxLength)
          .flatMap(validateStringNotEmpty),
    );
  }
}

class TodoName extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  const TodoName._(this.value);

  static const maxLength = 30;

  factory TodoName(String input) {
    return TodoName._(
      validateMaxStringLength(input, TodoName.maxLength)
          .flatMap(validateStringNotEmpty)
          .flatMap(validateSingleLine),
    );
  }
}

class NoteColor extends ValueObject<Color> {
  static const List<Color> predefinedColors = [
    Color(0xfffafafa),
    Color(0xfff44336),
    Color(0xfff58c1c),
    Color(0xfff9a825),
    Color(0xfff9c134),
    Color(0xfffbe9a3),
    Color(0xffffca28),
    Color(0xffffeb3b),
    Color(0xfff3e5f5),
  ];

  @override
  final Either<ValueFailure<Color>, Color> value;

  const NoteColor._(this.value);

  static const maxLength = 30;

  factory NoteColor(Color input) {
    return NoteColor._(right(makeColorOpaque(input)));
  }
}

class List3<T> extends ValueObject<KtList<T>> {
  @override
  final Either<ValueFailure<KtList<T>>, KtList<T>> value;

  const List3._(this.value);

  static const maxLength = 3;

  factory List3(KtList<T> input) {
    return List3._(validateMaxListLength(input, List3.maxLength));
  }

  int get length {
    return value.getOrElse(() => emptyList()).size;
  }

  bool get isFull => length == List3.maxLength;
}
