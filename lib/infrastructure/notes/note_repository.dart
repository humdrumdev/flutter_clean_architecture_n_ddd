import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:ddd_reso/domain/notes/i_note_repository.dart';
import 'package:ddd_reso/domain/notes/note_failure.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/infrastructure/notes/notes_dtos.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';
import 'package:ddd_reso/infrastructure/core/firestore_helpers.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: INoteRepository)
class NoteRepository implements INoteRepository {
  final FirebaseFirestore _firestore;

  NoteRepository(this._firestore);

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchAll() async* {
    final userDoc = _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => right<NoteFailure, KtList<Note>>(
            // fromFirestore factory needs update
            snapshot.docs
                .map((doc) => NoteDto.fromFirestore(doc).toDomain())
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((e, _) => left(getException(e)));
    // yield left(const NoteFailure.unexpected());
  }

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted() async* {
    final userDoc = _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NoteDto.fromFirestore(doc).toDomain()),
        )
        .map(
          (notes) => right<NoteFailure, KtList<Note>>(
            notes
                .where(
                  (note) =>
                      note.todos.getOrCrash().any((todoItem) => !todoItem.done),
                )
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((e, _) => left(getException(e)));
  }

  @override
  Future<Either<NoteFailure, Unit>> create(Note note) async {
    try {
      final userDoc = _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);

      await userDoc.noteCollection.doc(noteDto.id).set(noteDto.toJson());
      return right(unit);
    } on PlatformException catch (e) {
      return left(getException(e));
    } on FirebaseException catch (e) {
      return left(getException(e));
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> update(Note note) async {
    try {
      final userDoc = _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);

      await userDoc.noteCollection.doc(noteDto.id).update(noteDto.toJson());
      return right(unit);
    } on PlatformException catch (e) {
      return left(getException(e));
    } on FirebaseException catch (e) {
      return left(getException(e));
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> delete(Note note) async {
    try {
      final userDoc = _firestore.userDocument();
      final noteId = note.id.getOrCrash();

      await userDoc.noteCollection.doc(noteId).delete();
      return right(unit);
    } on PlatformException catch (e) {
      return left(getException(e));
    } on FirebaseException catch (e) {
      return left(getException(e));
    }
  }

  NoteFailure getException(Object e) {
    if (e is PlatformException && e.message!.contains('PERMISSION_DENIED')) {
      return const NoteFailure.insufficientPermisssion();
    }
    if (e is PlatformException && e.message!.contains('NOT_FOUND')) {
      return const NoteFailure.unableToUpdate();
    }
    print("exception not handled well!!");
    return const NoteFailure.unexpected();
  }
}
