import 'package:ddd_reso/application/notes/note_form/note_form_bloc.dart';
import 'package:ddd_reso/domain/notes/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NoteBodyField extends HookWidget {
  const NoteBodyField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (p, c) => p.isEditing != c.isEditing,
      listener: (context, state) {
        controller.text = state.note.body.getOrCrash();
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          autovalidateMode:
              BlocProvider.of<NoteFormBloc>(context).state.showErrorMessages
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Note',
            counterText: '',
          ),
          maxLength: NoteBody.maxLength,
          maxLines: null,
          minLines: 5,
          onChanged: (value) => BlocProvider.of<NoteFormBloc>(context)
              .add(NoteFormEvent.bodyChanged(value)),
          validator: (_) =>
              BlocProvider.of<NoteFormBloc>(context).state.note.body.value.fold(
                    (f) => f.maybeMap(
                      empty: (f) => 'Cannot be empty',
                      exceedingLength: (f) => 'Exceeding length, max: ${f.max}',
                      orElse: () => null,
                    ),
                    (r) => null,
                  ),
        ),
      ),
    );
  }
}
