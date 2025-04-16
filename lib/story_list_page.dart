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
          '${widget.mitoloji} Mitolojisi - ${widget.type == 'character' ? 'Karakterler' : 'Hikâyeler'}',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset('assets/story_bg.webp', fit: BoxFit.cover),
          ),
          // Blur efekti ve cam görünümü
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          // İçerik
          SafeArea(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : stories.isEmpty
                    ? const Center(
                      child: Text(
                        "Bu mitolojiye ait içerik bulunamadı.",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        children:
                            stories.map((story) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => StoryDetailPage(story: story),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 140,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 180,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image:
                                              story['image_url'] != null &&
                                                      story['image_url']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? DecorationImage(
                                                    image: NetworkImage(
                                                      story['image_url'],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : const DecorationImage(
                                                    image: AssetImage(
                                                      'assets/default_cover.jpg',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black38,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        story['title'] ?? "Başlık Yok",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
