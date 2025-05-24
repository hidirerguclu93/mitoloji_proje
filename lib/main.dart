import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_page.dart';
import 'chat_page.dart';
import 'mythology_selection_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'admin_panel_page.dart';


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
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0d090a),
      ),
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

  final List<IconData> icons = [Icons.home, Icons.auto_stories];
  final List<String> labels = ["Ana Sayfa", "Hikayeler"];

  void handleTap(int index) {
    setState(() => selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MythologySelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/anasayfa_arka_plan.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF241537).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(icons.length, (index) {
                  final isSelected = index == selectedIndex;
                  return IconButton(
                    onPressed: () => handleTap(index),
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icons[index],
                          color:
                              isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white70,
                          size: isSelected ? 34 : 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? const Color(0xFFFFD700)
                                    : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
    final user = Supabase.instance.client.auth.currentUser;
    const adminEmails = {"hidircanerguclu@gmail.com"};
    final isAdmin = adminEmails.contains(user?.email);

    return Drawer(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: const Color(0xFF241537).withOpacity(0.6)),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    "Mitoloji Menü",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.white),
                title: const Text(
                  "Arama",
                  style: TextStyle(color: Colors.white),
                ),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  "Profilim",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Admin Paneli",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminPanelPage(),
                        ),
                      ),
                ),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.white),
                title: Text(
                  user != null ? "Çıkış Yap" : "Giriş Yap",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  if (user != null) {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble, color: Colors.white),
                title: const Text(
                  "Sohbet",
                  style: TextStyle(color: Colors.white),
                ),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  "Ayarlar",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
