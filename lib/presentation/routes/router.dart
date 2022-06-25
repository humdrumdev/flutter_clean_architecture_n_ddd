import 'package:auto_route/auto_route.dart';
import 'package:ddd_reso/domain/notes/note.dart';
import 'package:ddd_reso/presentation/notes/note_form/note_form_page.dart';
import 'package:ddd_reso/presentation/notes/notes_overview/notes_overview.dart';
import 'package:ddd_reso/presentation/sign_in/sign_in_page.dart';
import 'package:ddd_reso/presentation/splash/splash_page.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  // replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: SignInPage),
    AutoRoute(page: NotesOverviewPage),
    AutoRoute(page: NoteFormPage, fullscreenDialog: true),
    
  ],
)
// extend the generated private router
class AppRouter extends _$AppRouter {}
