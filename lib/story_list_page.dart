import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryListPage extends StatefulWidget {
  final String mitoloji;

  const StoryListPage({super.key, required this.mitoloji});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> stories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('mythology_stories')
          .select()
          .eq('category', widget.mitoloji);

      setState(() {
        stories = List<Map<String, dynamic>>.from(response);
      });

      if (stories.isEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu mitoloji için henüz hikaye yok!"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      debugPrint("Hata oluştu: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hikayeler yüklenirken bir hata oluştu."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.mitoloji} Mitolojisi")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : stories.isEmpty
              ? const Center(
                  child: Text(
                    "Henüz hiç hikaye yok!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(
                          story['title'] ?? "Başlık Yok",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            story['content'] ?? "İçerik Yok",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryDetailPage(story: story),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.book, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                story['title'] ?? "Detay",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story['title'] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            Text(
              story['content'] ?? "",
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
