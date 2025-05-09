import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_detail_page.dart';

class StoryListPage extends StatefulWidget {
  final String mitoloji;
  final String type;

  const StoryListPage({super.key, required this.mitoloji, required this.type});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> stories = [];

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('mythology_stories')
          .select('title, content, image_url, story_uuid, category, type')
          .eq('category', widget.mitoloji)
          .eq('type', widget.type);

      if (mounted) {
        setState(() => stories = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hikayeler yüklenirken hata oluştu."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${widget.mitoloji} Mitolojisi - ${widget.type == 'character' ? 'Karakterler' : 'Hikayeler'}',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0E2A), Color(0xFF090517)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : stories.isEmpty
                    ? const Center(
                      child: Text(
                        "Bu mitolojiye ait içerik bulunamadı.",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryDetailPage(story: story),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(color: Colors.white24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      story['image_url'] ?? '',
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            height: 140,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.broken_image,
                                            ),
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      story['title'] ?? 'Başlık Yok',
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
