import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_detail_page.dart';

class StoryListPage extends StatefulWidget {
  final String mitoloji;
  const StoryListPage({super.key, required this.mitoloji});

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
          .select()
          .eq('category', widget.mitoloji);

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
      appBar: AppBar(
        title: Text("${widget.mitoloji} Mitolojisi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : stories.isEmpty
              ? const Center(
                child: Text(
                  "Bu mitolojiye ait hikaye bulunamadı.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
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
                                  builder: (_) => StoryDetailPage(story: story),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    width: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
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
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
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
    );
  }
}
