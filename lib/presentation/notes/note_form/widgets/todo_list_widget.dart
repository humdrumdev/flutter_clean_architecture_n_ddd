import 'package:another_flushbar/flushbar_helper.dart';
import 'package:ddd_reso/application/notes/note_form/note_form_bloc.dart';
import 'package:ddd_reso/domain/notes/value_objects.dart';
import 'package:ddd_reso/presentation/notes/note_form/misc/build_context_x.dart';
import 'package:ddd_reso/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kt_dart/kt.dart';
import 'package:provider/provider.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (p, c) => p.note.todos.isFull != c.note.todos.isFull,
      listener: (context, state) {
        if (state.note.todos.isFull) {
          FlushbarHelper.createAction(
            message: 'Todos limit reached, upgrade.',
            button: TextButton(
              onPressed: () {},
              child: const Text(
                'BUY NOW',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            duration: const Duration(seconds: 5),
          ).show(context);
        }
      },
      child: Consumer<FormTodos>(
        builder: (context, formTodos, child) {
          return ReorderableListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: formTodos.value.size,
            itemBuilder: (context, index) {
              return TodoTile(
                index: index,
                key: ValueKey(formTodos.value[index].id),
              );
            },
            onReorder: (prev, curr) {
              List<TodoItemPrimitive> todos = context.formTodos.asList();
              if (curr > prev) curr--;
              todos.insert(curr, todos.removeAt(prev));
              context.formTodos = todos.toImmutableList();
              BlocProvider.of<NoteFormBloc>(context).add(
                NoteFormEvent.todosChanged(context.formTodos),
              );
            },
          );
        },
      ),
    );
  }
}

class TodoTile extends HookWidget {
  final int index;
  const TodoTile({required this.index, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = context.formTodos.getOrElse(
      index,
      (_) => TodoItemPrimitive.empty(),
    );
    final controller = useTextEditingController(text: todo.name);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
      child: Material(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                spacing: 6.0,
                padding: const EdgeInsets.all(2.0),
                onPressed: (context) {
                  context.formTodos = context.formTodos.minusElement(todo);
                  BlocProvider.of<NoteFormBloc>(context).add(
                    NoteFormEvent.todosChanged(context.formTodos),
                  );
                },
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => todo == listTodo
                        ? todo.copyWith(done: value ?? false)
                        : listTodo,
                  );
                  BlocProvider.of<NoteFormBloc>(context).add(
                    NoteFormEvent.todosChanged(context.formTodos),
                  );
                },
              ),
              title: TextFormField(
                autovalidateMode: BlocProvider.of<NoteFormBloc>(context)
                        .state
                        .showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  counterText: '',
                  border: InputBorder.none,
                ),
                maxLength: TodoName.maxLength,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => todo == listTodo
                        ? todo.copyWith(name: value)
                        : listTodo,
                  );
                  BlocProvider.of<NoteFormBloc>(context).add(
                    NoteFormEvent.todosChanged(context.formTodos),
                  );
                },
                validator: (_) {
                  return BlocProvider.of<NoteFormBloc>(context)
                      .state
                      .note
                      .todos
                      .value
                      .fold(
                        (f) => null,
                        (todoList) => todoList[index].name.value.fold(
                              (f) => f.maybeMap(
                                empty: (_) => 'Todo must not be empty',
                                exceedingLength: (exceedingLength) =>
                                    'Todo must be less than ${exceedingLength.max} characters',
                                multiline: (_) =>
                                    'Todo must be in a single line',
                                orElse: () => null,
                              ),
                              (_) => null,
                            ),
                      );
                },
              ),
              trailing: const Icon(Icons.drag_handle_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
