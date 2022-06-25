import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ddd_reso/domain/auth/auth_failure.dart';
import 'package:ddd_reso/domain/auth/i_auth_facade.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/auth/value_objects.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';
part 'sign_in_form_bloc.freezed.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>((event, emit) async {
      if (event is EmailChanged) {
        emit(
          state.copyWith(
            emailAddress: EmailAddress(input: event.emailStr),
            authFailureOrSuccessOption: none(),
            // showErrorMessages: true,
          ),
        );
      } else if (event is PasswordChanged) {
        emit(
          state.copyWith(
            password: Password(input: event.passwordStr),
            authFailureOrSuccessOption: none(),
          ),
        );
      } else if (event is RegisterWithEmailAndPasswordPressed) {
        await _proceedWithEmailAndPassword(
          emit,
          _authFacade.registerWithEmailAndPassword,
        );
      } else if (event is SignInWithEmailAndPasswordPressed) {
        await _proceedWithEmailAndPassword(
          emit,
          _authFacade.signInWithEmailAndPassword,
        );
      } else if (event is SignInWithGooglePressed) {
        emit(
          state.copyWith(
            isSubmitting: true,
            authFailureOrSuccessOption: none(),
          ),
        );
        final failureOrSuccess = await _authFacade.signInWithGoogle();
        emit(
          state.copyWith(
            isSubmitting: false,
            authFailureOrSuccessOption: some(failureOrSuccess),
          ),
        );
      }
    });
  }

  Future<void> _proceedWithEmailAndPassword(
    Emitter<SignInFormState> emit,
    Future<Either<AuthFailure, Unit>> Function({
      required EmailAddress emailAddress,
      required Password password,
    })
        forwardedCall,
  ) async {
    Either<AuthFailure, Unit>? failureOrSuccess;

    final validEmail = state.emailAddress.isValid();
    final validPassword = state.password.isValid();

    if (validEmail && validPassword) {
      emit(
        state.copyWith(
          isSubmitting: true,
          authFailureOrSuccessOption: none(),
        ),
      );

      failureOrSuccess = await forwardedCall(
        emailAddress: state.emailAddress,
        password: state.password,
      );
    }
      emit(
        state.copyWith(
          isSubmitting: false,
          showErrorMessages: true,
          authFailureOrSuccessOption: optionOf(failureOrSuccess),
        ),
      );
  }
}
