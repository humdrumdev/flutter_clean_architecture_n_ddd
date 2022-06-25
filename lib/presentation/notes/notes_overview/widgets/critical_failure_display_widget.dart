import 'package:ddd_reso/domain/notes/note_failure.dart';
import 'package:flutter/material.dart';

class CriticalFailureDisplay extends StatelessWidget {
  final NoteFailure failure;
  const CriticalFailureDisplay({Key? key, required this.failure})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('😰️', style: TextStyle(fontSize: 100.0)),
          Text(
            failure.maybeMap(
              insufficientPermisssion: (_) => 'Insufficient permissions.',
              orElse: () => 'Unexpected error.\nPlease contact support.',
            ),
            style: const TextStyle(fontSize: 24.0),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              print("sending email..");
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.mail),
                SizedBox(width: 4.0),
                Text('I NEED HELP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
