import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchStories(String query) async {
    query = query.trim();

    if (query.length < 3) {
      // 3 harften azsa sonucu temizle
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('mythology_stories')
          .select()
          .ilike('title', '%$query%'); // İçeren başlıkları getir

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      debugPrint("Hata oluştu: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hikaye Arama")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "En az 3 harf yazın...",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: _searchStories,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _searchResults.isEmpty
                        ? const Center(child: Text("Sonuç bulunamadı"))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final story = _searchResults[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(story['title'] ?? "Başlık yok"),
                                  subtitle: Text(
                                    story['content'] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StoryDetailPage(story: story),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
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
      appBar: AppBar(title: Text(story['title'] ?? "Detay")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(story['content'] ?? "", style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
