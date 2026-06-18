import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/advance_task_status.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../presentation/blocs/schedule/schedule_bloc.dart';
import '../../presentation/blocs/work_order/work_order_bloc.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/ledger/completed_jobs_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/schedule/schedule_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/support_chat_screen.dart';
import '../../presentation/screens/work_order/work_order_screen.dart';
import '../constants/app_constants.dart';
import '../shell/main_shell.dart';

final _storage = const FlutterSecureStorage();

Future<String?> _authRedirect(BuildContext context, GoRouterState state) async {
  final token = await _storage.read(key: AppConstants.storageKeyAccessToken);
  final isAuth = token != null;
  final isOnLogin = state.uri.path == '/auth/login';
  if (!isAuth && !isOnLogin) return '/auth/login';
  if (isAuth && isOnLogin) return '/schedule';
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/schedule',
  redirect: _authRedirect,
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthBloc(),
        child: const LoginScreen(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/schedule',
          builder: (context, state) => BlocProvider(
            create: (ctx) => ScheduleBloc(
              taskRepository: TaskRepositoryImpl(
                remote: TaskRemoteDataSource(),
              ),
            ),
            child: ScheduleScreen(
              onOpenWorkOrder: (id) => context.push('/work-order/$id'),
            ),
          ),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(
            assignedTasks: [],
          ),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/analytics/history',
          builder: (context, state) => RepositoryProvider<TaskRepository>(
            create: (_) => TaskRepositoryImpl(remote: TaskRemoteDataSource()),
            child: const CompletedJobsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(),
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/support-chat',
      builder: (context, state) => const SupportChatScreen(),
    ),
    GoRoute(
      path: '/work-order/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        final taskRepo = TaskRepositoryImpl(remote: TaskRemoteDataSource());
        final chatRepo = ChatRepositoryImpl(remote: ChatRemoteDataSource());

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => WorkOrderBloc(
                taskRepository: taskRepo,
                advanceTaskStatus: AdvanceTaskStatus(taskRepo),
              ),
            ),
            BlocProvider(
              create: (_) => ChatBloc(chatRepository: chatRepo),
            ),
          ],
          child: WorkOrderScreen(taskId: taskId),
        );
      },
    ),
  ],
);
