import 'package:auto_route/auto_route.dart';
import 'package:ddd_reso/application/notes/note_actor/note_actor_bloc.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/domain/notes/todo_item.dart';
import 'package:ddd_reso/presentation/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/kt.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;

  const NoteCardWidget({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color.getOrCrash(),
      child: InkWell(
        onTap: () {
          context.router.push(NoteFormPageRoute(editedNote: note));
        },
        onLongPress: () {
          final noteActorBloc = BlocProvider.of<NoteActorBloc>(context);
          _showDeletionDialog(context, noteActorBloc);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                note.body.getOrCrash(),
                style: const TextStyle(fontSize: 18.0),
              ),
              if (note.todos.length > 0) ...[
                const SizedBox(height: 4.0),
                Wrap(
                  spacing: 8.0,
                  children: note.todos
                      .getOrCrash()
                      .map(
                        (todo) => TodoDisplay(todoItem: todo),
                      )
                      .iter
                      .toList(),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletionDialog(BuildContext context, NoteActorBloc noteActorBloc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selected note:'),
          content: Text(
            note.body.getOrCrash(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                noteActorBloc.add(NoteActorEvent.deleted(note));
                Navigator.pop(context);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
}

class TodoDisplay extends StatelessWidget {
  final TodoItem todoItem;

  const TodoDisplay({Key? key, required this.todoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (todoItem.done)
          Icon(
            Icons.check_box,
            color: Theme.of(context).colorScheme.secondary,
          ),
        if (!todoItem.done)
          Icon(
            Icons.check_box_outline_blank,
            color: Theme.of(context).disabledColor,
          ),
        Text(todoItem.name.getOrCrash()),
      ],
    );
  }
}
