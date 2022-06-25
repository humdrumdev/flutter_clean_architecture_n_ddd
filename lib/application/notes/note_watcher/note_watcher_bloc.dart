import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ddd_reso/domain/notes/i_note_repository.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/domain/notes/note_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';

part 'note_watcher_event.dart';
part 'note_watcher_state.dart';
part 'note_watcher_bloc.freezed.dart';

@injectable
class NoteWatcherBloc extends Bloc<NoteWatcherEvent, NoteWatcherState> {
  final INoteRepository _noteRepository;

  StreamSubscription<Either<NoteFailure, KtList<Note>>>?
      _noteStreamSubscription;

  NoteWatcherBloc(this._noteRepository) : super(const _Initial()) {
    on<NoteWatcherEvent>((event, emit) {
      event.map(
        watchAllStarted: (e) async {
          emit(const NoteWatcherState.loadInProgress());
          await _noteStreamSubscription?.cancel();
          _noteStreamSubscription = _noteRepository.watchAll().listen(
                (failureOrNotes) => add(
                  NoteWatcherEvent.notesReceived(failureOrNotes),
                ),
              );
        },
        watchUncompletedStarted: (e) async {
          emit(const NoteWatcherState.loadInProgress());
          await _noteStreamSubscription?.cancel();
          _noteStreamSubscription = _noteRepository.watchUncompleted().listen(
                (failureOrNotes) => add(
                  NoteWatcherEvent.notesReceived(failureOrNotes),
                ),
              );
        },
        notesReceived: (e) {
          e.failureOrNotes.fold(
            (f) => emit(NoteWatcherState.loadFailure(f)),
            (notes) => emit(NoteWatcherState.loadSuccess(notes)),
          );
        },
      );
    });
  }

  @override
  Future<void> close() async {
    await _noteStreamSubscription?.cancel();
    return super.close();
  }
}
