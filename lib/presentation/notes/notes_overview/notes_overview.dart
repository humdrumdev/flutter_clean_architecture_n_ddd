import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ddd_reso/application/auth/auth_bloc.dart';
import 'package:ddd_reso/application/notes/note_actor/note_actor_bloc.dart';
import 'package:ddd_reso/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:ddd_reso/injection.dart';
import 'package:ddd_reso/presentation/notes/notes_overview/widgets/notes_overview_body.dart';
import 'package:ddd_reso/presentation/notes/notes_overview/widgets/uncompleted_switch.dart';
import 'package:ddd_reso/presentation/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesOverviewPage extends StatelessWidget {
  const NotesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteWatcherBloc>(
          create: (context) => getIt<NoteWatcherBloc>()
            ..add(const NoteWatcherEvent.watchAllStarted()),
        ),
        BlocProvider<NoteActorBloc>(
          create: (context) => getIt<NoteActorBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.maybeMap(
                unauthenticated: (_) =>
                    context.router.replace(const SignInPageRoute()),
                orElse: () {},
              );
            },
          ),
          BlocListener<NoteActorBloc, NoteActorState>(
              listener: (context, state) {
            state.maybeMap(
              deleteFailure: (state) {
                FlushbarHelper.createError(
                  duration: const Duration(seconds: 5),
                  message: state.failure.map(
                    unexpected: (_) =>
                        'Unexpected error occured while deleting',
                    insufficientPermisssion: (_) => 'Insufficient permissions',
                    noteNotFound: (_) => 'Unused Error',
                    unableToUpdate: (_) => 'Impossible Error',
                    db: (_) => 'Unused Error',
                  ),
                ).show(context);
              },
              orElse: () {},
            );
          }),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notes'),
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context)
                    .add(const AuthEvent.signedOut());
              },
            ),
            actions: const <Widget>[
              UncompletedSwitch(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.router.push(NoteFormPageRoute(editedNote: null));
            },
            child: const Icon(Icons.add),
          ),
          body: const NotesOverviewBody(),
        ),
      ),
    );
  }
}
