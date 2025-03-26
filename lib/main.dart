import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'search_page.dart';
import 'map_screen.dart';
import 'chat_page.dart';
import 'mythology_selection_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hwsfigyagjtorzvbdqrp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3c2ZpZ3lhZ2p0b3J6dmJkcXJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMDc5NTUsImV4cCI6MjA1Nzg4Mzk1NX0.mJhO-InFZddtsX_iGV1vIv4fYHBkRs9easkwrc4c5K4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<IconData> icons = [Icons.home, Icons.book, Icons.map];
  final List<String> labels = ["Ana Sayfa", "Hikayeler", "Harita"];

  void handleTap(int index) {
    setState(() => selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MythologySelectionPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/olympus_background.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Builder(
              builder:
                  (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.4 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.7 * 255).toInt()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(icons.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.translationValues(
                          0,
                          isSelected ? -8 : 0,
                          0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icons[index],
                              size: 42,
                              color:
                                  isSelected
                                      ? Colors.lightBlueAccent
                                      : Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[index],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.lightBlueAccent
                                        : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Text(
              "Menü",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text("Arama"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Sohbet Odası"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Giriş Yap"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Ayarlar"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Yama Notları"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
