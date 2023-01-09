import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

Future<void> restartApp(BuildContext context) async {
  RestartWidget.restartApp(context);
  print("app restarted");
}

void main() async {
  // unsure why this is needed, but some package is using stack traces from the stack_trace package
  // rather than native Flutter stack traces
  // https://api.flutter.dev/flutter/foundation/FlutterError/demangleStackTrace.html
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    RestartWidget(
      child: TestApp(),
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
    return const ProviderScope(
        child: MaterialApp(
      title: 'App',
      home: HomeScreen(),
    ));
  }
}

class HomeScreen extends ConsumerWidget {
  static const route = "/home";
  static const name = "home";

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
    // bug cause #1
    final user = ref.watch(UserProviders.currentUser);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: TeamSelector(),
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
    // bug cause #2
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

class TeamSelector extends ConsumerWidget {
  const TeamSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(UserProviders.teams).value ?? [];

    return Container();
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
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
