import 'package:bloc/bloc.dart';
import 'package:ddd_reso/domain/notes/i_note_repository.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/domain/notes/note_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'note_actor_event.dart';
part 'note_actor_state.dart';
part 'note_actor_bloc.freezed.dart';

@injectable
class NoteActorBloc extends Bloc<NoteActorEvent, NoteActorState> {
  final INoteRepository _noteRepository;

  NoteActorBloc(this._noteRepository) : super(const _Initial()) {
    on<NoteActorEvent>((event, emit) async {
      emit(const NoteActorState.actionInProgress());
      final possibleFailure = await _noteRepository.delete(event.note);
      possibleFailure.fold(
      (f) => emit(NoteActorState.deleteFailure(f)),
      (r) => emit(const NoteActorState.deleteSuccess()),
      );
    });
  }
}
