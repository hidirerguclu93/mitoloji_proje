import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_page.dart';
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
  bool _isDrawerOpen = false;

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
        leading:
            _isDrawerOpen
                ? null
                : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => setState(() => _isDrawerOpen = true),
                ),
      ),

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
          if (_isDrawerOpen)
            buildGlassDrawer(
              context,
              () => setState(() => _isDrawerOpen = false),
            ),
        ],
      ),
    );
  }
}

Widget buildGlassDrawer(BuildContext context, VoidCallback closeDrawer) {
  final user = Supabase.instance.client.auth.currentUser;
  const adminEmails = {"hidircanerguclu@gmail.com"};
  final isAdmin = adminEmails.contains(user?.email);

  return GestureDetector(
    onTap: closeDrawer,
    child: Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              children: [
                const Text(
                  "Mitoloji Menü",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _drawerItem(
                  context,
                  Icons.search,
                  "Arama",
                  const SearchPage(),
                  closeDrawer,
                ),
                _drawerItem(
                  context,
                  Icons.person,
                  "Profilim",
                  user != null ? const ProfilePage() : const LoginPage(),
                  closeDrawer,
                ),
                if (isAdmin)
                  _drawerItem(
                    context,
                    Icons.admin_panel_settings,
                    "Admin Paneli",
                    const AdminPanelPage(),
                    closeDrawer,
                  ),
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: Text(
                    user != null ? "Çıkış Yap" : "Giriş Yap",
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    closeDrawer();
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

                const ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text("Ayarlar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _drawerItem(
  BuildContext context,
  IconData icon,
  String title,
  Widget page,
  VoidCallback closeDrawer,
) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    onTap: () {
      closeDrawer();
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    },
  );
}
