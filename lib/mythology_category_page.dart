import 'package:flutter/material.dart';
import 'dart:ui';
import 'story_list_page.dart';

class MythologyCategoryPage extends StatelessWidget {
  final String selectedMythology;

  const MythologyCategoryPage({Key? key, required this.selectedMythology})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hikâyeler Bölgesi
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StoryListPage(
                          mitoloji: selectedMythology,
                          type: 'chronological',
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/history_banner.webp',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.35),
                        alignment: Alignment.center,
                        child: const Text(
                          '📖 Hikâyeleri Gör',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Karakterler Bölgesi
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StoryListPage(
                          mitoloji: selectedMythology,
                          type: 'character',
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/god_banner.webp', fit: BoxFit.cover),
                      Container(
                        color: Colors.black.withOpacity(0.35),
                        alignment: Alignment.center,
                        child: const Text(
                          '👤 Karakterleri Gör',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
