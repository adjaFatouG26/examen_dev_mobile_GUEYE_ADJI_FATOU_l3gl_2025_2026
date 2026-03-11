import 'package:flutter/material.dart';
import 'package:sunu_task/core/theme/app_theme.dart';
import 'package:sunu_task/screens/splash/splash_screen.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  runApp(const SunuTask());
}

class SunuTask extends StatefulWidget {
  const SunuTask({super.key});

  @override
  State<SunuTask> createState() => _SunuTaskState();
}

class _SunuTaskState extends State<SunuTask> {
  // Déclaration des providers
  final _appProvider = AppProvider();
  final _authProvider = AuthProvider();
  final _projectProvider = ProjectProvider();
  final _taskProvider = TaskProvider();

  @override
  void initState() {
    super.initState();
    // Initialisation des providers
    _appProvider.init();
    _authProvider.init();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
