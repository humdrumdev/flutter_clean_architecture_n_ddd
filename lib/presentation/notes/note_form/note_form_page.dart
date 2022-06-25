import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:ddd_reso/application/notes/note_form/note_form_bloc.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/injection.dart';
import 'package:ddd_reso/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';
import 'package:ddd_reso/presentation/notes/note_form/widgets/add_todo_tile_widget.dart';
import 'package:ddd_reso/presentation/notes/note_form/widgets/body_field_widget.dart';
import 'package:ddd_reso/presentation/notes/note_form/widgets/color_field_widget.dart';
import 'package:ddd_reso/presentation/notes/note_form/widgets/todo_list_widget.dart';
import 'package:ddd_reso/presentation/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class NoteFormPage extends StatelessWidget {
  final Note? editedNote;
  const NoteFormPage({Key? key, this.editedNote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => getIt<NoteFormBloc>()
        ..add(
          NoteFormEvent.initialized(
            optionOf(editedNote),
          ),
        ),
      child: BlocConsumer<NoteFormBloc, NoteFormState>(
          listenWhen: (p, c) =>
              p.saveFailureOrSuccessOption != c.saveFailureOrSuccessOption,
          listener: (context, state) {
            state.saveFailureOrSuccessOption.fold(
              () {},
              (either) => either.fold(
                (failure) {
                  FlushbarHelper.createError(
                    message: failure.map(
                      unexpected: (_) => 'Unexpected error.',
                      insufficientPermisssion: (_) =>
                          'Insufficient permissions.',
                      noteNotFound: (_) => 'note not found.',
                      unableToUpdate: (_) => 'unable to update.',
                      db: (_) => 'db error',
                    ),
                  ).show(context);
                },
                (r) {
                  context.router.popUntil(
                    (route) =>
                        route.settings.name == NotesOverviewPageRoute.name,
                  );
                },
              ),
            );
          },
          buildWhen: (p, c) => p.isSaving != c.isSaving,
          builder: (context, state) {
            return Stack(
              children: [
                const NoteFormPageScaffold(),
                SavingInProgressOverlay(
                  isSaving: state.isSaving,
                ),
              ],
            );
          }),
    );
  }
}

class SavingInProgressOverlay extends StatelessWidget {
  final bool isSaving;
  const SavingInProgressOverlay({
    Key? key,
    required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isSaving,
      child: AnimatedContainer(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        duration: const Duration(milliseconds: 150),
        color: isSaving ? Colors.black.withOpacity(0.8) : Colors.transparent,
        child: Visibility(
          visible: isSaving,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'Saving',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NoteFormPageScaffold extends StatelessWidget {
  const NoteFormPageScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<NoteFormBloc, NoteFormState>(
            buildWhen: (p, c) => p.isEditing != c.isEditing,
            builder: ((context, state) =>
                Text(state.isEditing ? 'Edit a note' : 'Create a note')),
          ),
          actions: [
            IconButton(
              onPressed: () {
                BlocProvider.of<NoteFormBloc>(context).add(
                  const NoteFormEvent.saved(),
                );
              },
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        body: BlocBuilder<NoteFormBloc, NoteFormState>(
          buildWhen: (p, c) => p.showErrorMessages != c.showErrorMessages,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (context) => FormTodos(),
              child: Form(
                autovalidateMode: state.showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      NoteBodyField(),
                      ColorField(),
                      TodoList(),
                      AddTodoTile(),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
