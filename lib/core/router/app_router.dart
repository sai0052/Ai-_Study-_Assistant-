import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../features/campus/presentation/screens/campus_feed_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notes/domain/entities/note_entity.dart';
import '../../features/notes/presentation/screens/note_detail_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/study_planner/presentation/screens/study_planner_screen.dart';
import '../../features/tasks/presentation/screens/add_edit_task_screen.dart';
import '../../features/tasks/presentation/screens/tasks_list_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Central GoRouter configuration.
///
/// Key ideas for a beginner reading this:
/// 1. `redirect` runs on every navigation and enforces the auth gate — if
///    there's no signed-in user, every route except /login and /register
///    bounces back to /login. This is the ONLY place auth-gating logic lives.
/// 2. The 5 bottom-nav tabs (Dashboard, Tasks, AI Chat, Notes, Profile) are
///    declared as top-level routes and wrapped in a shared Scaffold via
///    `MainShellScreen` so the bottom nav bar persists across them.
/// 3. Routes like /notes/new or /tasks/new are pushed ON TOP of the shell
///    (full-screen, with a back button) rather than being tabs themselves.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(ref.watch(authRepositoryProvider).authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null; // no redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),

      // Bottom-nav tabs, each wrapped in the shared shell scaffold.
      ShellRoute(
        builder: (context, state, child) => _ShellWithNav(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/tasks', builder: (context, state) => const TasksListScreen()),
          GoRoute(path: '/ai-chat', builder: (context, state) => const AiChatScreen()),
          GoRoute(path: '/notes', builder: (context, state) => const NotesListScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),

      // Full-screen routes pushed on top of the shell (no bottom nav visible).
      GoRoute(path: '/tasks/new', builder: (context, state) => const AddEditTaskScreen()),
      GoRoute(path: '/notes/new', builder: (context, state) => const NoteEditorScreen()),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final note = state.extra as NoteEntity;
          return NoteDetailScreen(note: note);
        },
      ),
      GoRoute(path: '/campus', builder: (context, state) => const CampusFeedScreen()),
      GoRoute(path: '/study-planner', builder: (context, state) => const StudyPlannerScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
    ],
  );
});

/// Maps the 5 shell routes to bottom-nav tab indices and renders
/// MainShellScreen around whichever tab GoRouter is currently showing.
class _ShellWithNav extends StatelessWidget {
  final Widget child;
  const _ShellWithNav({required this.child});

  static const _tabPaths = ['/dashboard', '/tasks', '/ai-chat', '/notes', '/profile'];

  int _indexForLocation(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabPaths.indexOf(location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexForLocation(context);
    return MainShellScreen(
      currentIndex: currentIndex,
      onTap: (index) => context.go(_tabPaths[index]),
      child: child,
    );
  }
}

/// Bridges a Stream (Firebase auth state) into a Listenable that GoRouter's
/// `refreshListenable` can consume, so the router automatically re-evaluates
/// `redirect` whenever the user signs in or out — no manual navigation needed.
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _stream = stream.asBroadcastStream();
    _stream.listen((_) => notifyListeners());
  }
}
