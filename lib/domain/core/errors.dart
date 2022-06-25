import 'package:ddd_reso/domain/core/failures.dart';

class NotAuthenticatedError extends Error {}

class UnexpectedValueError extends Error {
  final ValueFailure valueFailure;

  UnexpectedValueError({
    required this.valueFailure,
  });

  @override
  String toString() {
    return Error.safeToString(
      'Error: Unexpected Value at advanced stage: $valueFailure',
    );
  }
}

