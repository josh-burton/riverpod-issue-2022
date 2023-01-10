import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Restart the app by re-running the main method (and calling runApp again).
///
Future<void> restartApp(BuildContext context) async {
  scheduleMicrotask(() {
    // call runApp twice in order to work around the issue
    // runApp(MaterialApp());

    main();
    print("app restarted");
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    TestApp(
      key: UniqueKey(),
    ),
  );
}

// Widgets

class TestApp extends ConsumerWidget {
  const TestApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      child: MaterialApp(
        title: 'App',
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    // watch providers to ensure both tabs have fresh data
    ref.watch(providerOfAppModel);

    return const Scaffold(
      body: DashboardPage(),
    );
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final user = ref.watch(UserProviders.currentUser);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: [],
      ),
      body: _DashboardBody(),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(providerOfAppModel);

    return Center(
      child: ElevatedButton(
        onPressed: () {
          restartApp(context);
        },
        child: Text("Restart (press twice)"),
      ),
    );
  }
}
// Providers
final providerOfAppModel = ChangeNotifierProvider<AppModel>(
  (ref) {
    try {
      return AppModel(
        user: ref.watch(UserProviders.currentUser).valueOrNull,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  },
  name: 'AppModel.provider',
);

class AppModel with ChangeNotifier {
  final String? user;

  AppModel({
    required this.user,
  });
}

class UserProviders {
  UserProviders._();

  static final currentUser = StreamProvider<String?>(
    (ref) async* {
      yield "";
    },
    name: "UserProviders.currentUser",
  );

  static final teams = FutureProvider.autoDispose<List<String>>(
    (ref) async {
      try {
        final user = await ref.watch(currentUser.future);
        return [];
      } catch (e, stack) {
        print(
          "Failed to get teams",
        );
        print(e);
        print(stack);
        rethrow;
      }
    },
    dependencies: [
      currentUser,
    ],
    name: "UserProviders.teams",
  );
}
