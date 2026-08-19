import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/profile/profile_screen.dart';
import '../screens/library/library_screen.dart';

import '../screens/space/canvas_space_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/main/recents_screen.dart';
import '../screens/ai/ai_chat_screen.dart';
import '../screens/ai/voice_assistant_screen.dart';
import '../screens/capture/media_viewer_screen.dart';
import '../widgets/layout/app_shell.dart';
import '../screens/modules/assignments_screen.dart';
import '../screens/modules/calendar_screen.dart';
import '../screens/modules/canvas_screen.dart';
import '../screens/modules/finance_screen.dart';
import '../screens/modules/focus_screen.dart';
import '../screens/modules/forge_screen.dart';
import '../screens/modules/document_screen.dart';
import '../screens/modules/memories_screen.dart';
import '../screens/modules/mood_screen.dart';
import '../screens/modules/reading_screen.dart';
import '../screens/modules/research_screen.dart';
import '../screens/modules/startup_screen.dart';
import '../screens/modules/study_screen.dart';
import '../screens/modules/tasks_screen.dart';



final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: SearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: LibraryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),

        GoRoute(
          path: '/ai',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: AiChatScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/recents',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RecentsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/voice',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const VoiceAssistantScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/modules/assignments',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: AssignmentsModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/calendar',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: CalendarModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
          GoRoute(
            path: '/modules/canvas',
            pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: CanvasModuleScreen(), 
transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
          ),
        GoRoute(
          path: '/modules/finance',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: FinanceModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/focus',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: FocusModeScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
          GoRoute(
            path: '/modules/forge',
            pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: ForgeModuleScreen(), 
transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
          ),
        GoRoute(
          path: '/modules/memories',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: MemoriesScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/mood',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: MoodModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
          GoRoute(
            path: '/modules/document',
            pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: DocumentModuleScreen(), 
transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
          ),
        GoRoute(
          path: '/modules/reading',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: ReadingModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/research',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: ResearchScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/startup',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: StartupModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/study',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: StudyModuleScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
        GoRoute(
          path: '/modules/tasks',
          pageBuilder: (context, state) => CustomTransitionPage(key: state.pageKey, child: TasksScreen(), transitionsBuilder: (context, a, s, c) => FadeTransition(opacity: a, child: c)),
        ),
      ],
    ),
    GoRoute(
      path: '/capture/viewer',
      builder: (context, state) {
        final capture = state.extra as dynamic;
        if (capture != null) {
          return MediaViewerScreen(capture: capture);
        }
        return Scaffold(body: Center(child: Text('Capture not found')));
      },
    ),
    // Test route for canvas space
    GoRoute(
      path: '/canvas-space',
      builder: (context, state) => const CanvasSpaceScreen(),
    ),
  ],
);



