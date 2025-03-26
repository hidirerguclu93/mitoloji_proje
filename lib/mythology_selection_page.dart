import 'package:flutter/material.dart';
import 'story_list_page.dart'; // Add this import statement

class MythologySelectionPage extends StatelessWidget {
  const MythologySelectionPage({super.key});

  final List<Map<String, dynamic>> mythologies = const [
    {"name": "Yunan", "image": "assets/icons/zeus.png"},
    {"name": "Mısır", "image": "assets/icons/eye-of-horus.png"},
    {"name": "İskandinav", "image": "assets/icons/odin.png"},
    {"name": "Türk", "image": "assets/icons/wolf.png"},
    {"name": "Japon", "image": "assets/icons/amaterasu.png"},
    {"name": "Hint", "image": "assets/icons/ganesha.png"},
    {"name": "Çin", "image": "assets/icons/chinese.png"},
    {"name": "Aztek", "image": "assets/icons/aztek.png"},
    {"name": "Yerli", "image": "assets/icons/eagle.png"},
    {"name": "Slav", "image": "assets/icons/slav_bear.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mitolojini Seç"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg_texture.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(
                (0.2 * 255).toInt(),
              ), // Uyarı giderildi
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withAlpha(
                  (0.4 * 255).toInt(),
                ), // Uyarı giderildi
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children:
                    mythologies.map((myth) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      StoryListPage(mitoloji: myth["name"]),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                myth["image"] as String,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myth["name"] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
