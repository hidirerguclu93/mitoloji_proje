import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> results = [];

  Future<void> searchStories(String query) async {
    final res = await Supabase.instance.client
        .from('mythology_stories')
        .select()
        .ilike('title', '%$query%');

    setState(() {
      results = List<Map<String, dynamic>>.from(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arama"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Hikaye ara...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchStories(_controller.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final story = results[index];
                return ListTile(
                  title: Text(story['title'] ?? 'Başlıksız'),
                  subtitle: Text(
                    story['category'] ?? 'Kategori Yok',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryDetailPage(story: story),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
