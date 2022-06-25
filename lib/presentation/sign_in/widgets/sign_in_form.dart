import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ddd_reso/application/auth/auth_bloc.dart';
import 'package:ddd_reso/presentation/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/auth/sign_in_form/sign_in_form_bloc.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccessOption.fold(
          () => null,
          (either) => either.fold(
            (failure) {
              FlushbarHelper.createError(
                message: failure.map(
                  cancelledByUser: (_) => "Canceled",
                  serverError: (_) => "Server Error",
                  emailAlreadyInUse: (_) => "Email already in use",
                  invalidEmailAndPasswordCombination: (_) =>
                      "Invalid Email And Password Combination",
                ),
              ).show(context);
            },
            (_) {
              context.router.replace(const NotesOverviewPageRoute());
              BlocProvider.of<AuthBloc>(context).add(const AuthEvent.authCheckRequested());
            },
          ),
        );
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          onChanged: () {},
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              const Icon(Icons.person, size: 150),
              const SizedBox(height: 12),
              TextFormField(
                onChanged: (value) =>
                    BlocProvider.of<SignInFormBloc>(context).add(
                  SignInFormEvent.emailChanged(value),
                ),
                validator: (_) {
                  return BlocProvider.of<SignInFormBloc>(context)
                      .state
                      .emailAddress
                      .value
                      .fold(
                        (f) => f.maybeMap(
                          invalidEmail: (_) => 'Invalid email',
                          orElse: () => null,
                        ),
                        (_) => null,
                      );
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                onChanged: (value) =>
                    BlocProvider.of<SignInFormBloc>(context).add(
                  SignInFormEvent.passwordChanged(value),
                ),
                validator: (_) {
                  return BlocProvider.of<SignInFormBloc>(context)
                      .state
                      .password
                      .value
                      .fold(
                        (f) => f.maybeMap(
                          shortPassword: (_) => 'Short password',
                          orElse: () => null,
                        ),
                        (_) => null,
                      );
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                autocorrect: false,
                obscureText: true,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      child: const Text('SIGN IN'),
                      onPressed: () {
                        BlocProvider.of<SignInFormBloc>(context).add(
                          const SignInFormEvent
                              .signInWithEmailAndPasswordPressed(),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: const Text('REGISTER'),
                      onPressed: () {
                        BlocProvider.of<SignInFormBloc>(context).add(
                          const SignInFormEvent
                              .registerWithEmailAndPasswordPressed(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<SignInFormBloc>(context).add(
                    const SignInFormEvent.signInWithGooglePressed(),
                  );
                },
                child: const Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.isSubmitting) ...[
                const SizedBox(
                  height: 8.0,
                ),
                const LinearProgressIndicator(value: null),
              ]
            ],
          ),
        );
      },
    );
  }
}
