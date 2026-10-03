import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/aida_state.dart';
import 'screens/chat_screen.dart';
import 'screens/help_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AidaState()..init(),
      child: const AidaApp(),
    ),
  );
}

class AidaApp extends StatelessWidget {
  const AidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIDA',
      debugShowCheckedModeBanner: false,
      theme: AidaTheme.light(),
      darkTheme: AidaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AidaHome(),
    );
  }
}

class AidaHome extends StatefulWidget {
  const AidaHome({super.key});

  @override
  State<AidaHome> createState() => _AidaHomeState();
}

class _AidaHomeState extends State<AidaHome> {
  int _currentIndex = 0;

  static const _titles = ['AIDA', 'Ayuda', 'Mi perfil', 'Ajustes'];

  final _screens = const [
    ChatScreen(),
    HelpScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Ayuda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
