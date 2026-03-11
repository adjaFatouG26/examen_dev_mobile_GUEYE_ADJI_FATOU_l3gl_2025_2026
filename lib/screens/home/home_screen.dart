import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Index onglet actif
  int _currentIndex = 0;

  // Providers
  final _authProvider = AuthProvider();
  final _projectProvider = ProjectProvider();
  final _taskProvider = TaskProvider();

  // Titres des onglets
  final List<String> _titles = [
    'Dashboard',
    'Projets',
    'Tâches',
    'Profil',
  ];

  @override
  void initState() {
    super.initState();
    _authProvider.init();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _authProvider.currentUser;
    if (user != null) {
      await _projectProvider.loadProjects(user.id);
    }
  }

  Future<void> _logout() async {
    await _authProvider.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(authProvider: _authProvider, projectProvider: _projectProvider, taskProvider: _taskProvider),
          ProjectsTab(authProvider: _authProvider, projectProvider: _projectProvider),
          TasksTab(projectProvider: _projectProvider, taskProvider: _taskProvider),
          ProfileTab(authProvider: _authProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tâches'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _currentIndex == 1 || _currentIndex == 2
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: ListenableBuilder(
              listenable: _authProvider,
              builder: (context, _) {
                final user = _authProvider.currentUser;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(user?.name ?? 'Utilisateur',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                );
              },
            ),
          ),
          ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'),
              onTap: () { setState(() => _currentIndex = 0); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.folder), title: const Text('Projets'),
              onTap: () { setState(() => _currentIndex = 1); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.task), title: const Text('Tâches'),
              onTap: () { setState(() => _currentIndex = 2); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.person), title: const Text('Profil'),
              onTap: () { setState(() => _currentIndex = 3); Navigator.pop(context); }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}