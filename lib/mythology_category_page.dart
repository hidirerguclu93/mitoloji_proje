import 'package:flutter/material.dart';
import 'dart:ui';
import 'story_list_page.dart';

class MythologyCategoryPage extends StatelessWidget {
  final String selectedMythology;

  const MythologyCategoryPage({super.key, required this.selectedMythology});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(selectedMythology),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1127), Color(0xFF3E1C32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/history_banner.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.2),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '📖 Hikâyeleri Gör',
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black87,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/god_banner.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.2),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '👤 Karakterleri Gör',
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black87,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
