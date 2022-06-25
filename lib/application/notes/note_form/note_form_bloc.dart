import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ddd_reso/domain/notes/i_note_repository.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/domain/notes/note_failure.dart';
import 'package:ddd_reso/domain/notes/value_objects.dart';
import 'package:ddd_reso/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';

part 'note_form_event.dart';
part 'note_form_state.dart';
part 'note_form_bloc.freezed.dart';

@injectable
class NoteFormBloc extends Bloc<NoteFormEvent, NoteFormState> {
  final INoteRepository _noteRepository;

  NoteFormBloc(this._noteRepository) : super(NoteFormState.initial()) {
    on<NoteFormEvent>((event, emit) async {
      await event.map(
        initialized: (e) {
          e.initialNoteOption.fold(
            () => emit(state),
            (initialNote) => emit(
              state.copyWith(note: initialNote, isEditing: true),
            ),
          );
        },
        bodyChanged: (e) {
          emit(
            state.copyWith(
              note: state.note.copyWith(
                body: NoteBody(e.bodyStr),
              ),
              saveFailureOrSuccessOption: none(),
            ),
          );
        },
        colorChanged: (e) {
          emit(
            state.copyWith(
              note: state.note.copyWith(color: NoteColor(e.noteColor)),
              saveFailureOrSuccessOption: none(),
            ),
          );
        },
        todosChanged: (e) {
          emit(
            state.copyWith(
              note: state.note.copyWith(
                todos: List3(e.todos.map((primitive) => primitive.toDomain())),
              ),
              saveFailureOrSuccessOption: none(),
            ),
          );
        },
        saved: (e) async {
          Either<NoteFailure, Unit>? failureOrSuccess;
          emit(
            state.copyWith(
              isSaving: true,
              saveFailureOrSuccessOption: none(),
            ),
          );

          await state.note.failureOption.fold(
            () async {
              final Future<Either<NoteFailure, Unit>> Function(Note note) call;
              call = state.isEditing
                  ? _noteRepository.update
                  : _noteRepository.create;

              failureOrSuccess = await call(state.note);

              emit(
                state.copyWith(
                  isSaving: false,
                  showErrorMessages: true,
                  saveFailureOrSuccessOption: optionOf(failureOrSuccess),
                ),
              );
            },
            (failure) {
              emit(
                state.copyWith(
                  isSaving: false,
                  showErrorMessages: true,
                  saveFailureOrSuccessOption: none(),
                ),
              );
            },
          );
        },
      );
    });
  }
}
