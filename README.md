# riverpod_restart_bug

Demonstrates a bug in Riverpod where calling runApp to re-create the app will cause the following error to be thrown:

```
Unhandled Exception: setState() or markNeedsBuild() called during build.
This HomeScreen widget cannot be marked as needing to build because the framework is already in the process of building widgets. A widget can be marked as needing to be built during the build phase only if one of its ancestors is currently building. This exception is allowed because the framework builds parent widgets before children, which means a dirty descendant will always be built. Otherwise, the framework might not visit this widget during this build phase.
The widget on which setState() or markNeedsBuild() was called was:
  HomeScreen
The widget which was currently being built when the offending call was made was:
  _DashboardBody
#0      Element.markNeedsBuild.<anonymous closure> (package:flutter/src/widgets/framework.dart:4549:11)
#1      Element.markNeedsBuild (package:flutter/src/widgets/framework.dart:4564:6)
#2      ConsumerStatefulElement.watch.<anonymous closure>.<anonymous c<…>
```

### Work around

Calling runApp twice seems to fix the issue.

e.g. before calling main/runApp of the app, call a temporary `runApp(MaterialApp())` and then call main. The errors no
longer appear.