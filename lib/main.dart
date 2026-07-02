import "package:flutter/material.dart";
import "package:help_out/app/app_widget.dart";
import "package:help_out/app/bindings/app_bindings.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings().dependencies();
  runApp(const AppWidget());
}
