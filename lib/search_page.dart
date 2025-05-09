import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> categories = [
    'Hepsi', // <-- Yeni eklendi
    'Yunan',
    'Mısır',
    'İskandinav',
    'Türk',
    'Japon',
    'Hint',
    'Çin',
    'Aztek',
    'Yerli',
    'Slav',
  ];

  String selectedCategory = 'Hepsi';
  List<Map<String, dynamic>> results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _controller.text.trim();
      if (query.length >= 3) {
        searchStories(query);
      } else {
        setState(() => results.clear());
      }
    });
  }

  Future<void> searchStories(String query) async {
    setState(() => _isLoading = true);
    try {
      final queryBuilder = Supabase.instance.client
          .from('mythology_stories')
          .select()
          .ilike('title', '%$query%');

      if (selectedCategory != 'Hepsi') {
        queryBuilder.eq('category', selectedCategory);
      }

      final res = await queryBuilder;

      setState(() {
        results = List<Map<String, dynamic>>.from(res);
      });
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Arama"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0d090a)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF241537).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Mitoloji Seç",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                        ),
                        dropdownColor: const Color(0xFF241537),
                        style: const TextStyle(color: Colors.white),
                        items:
                            categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedCategory = val;
                              if (_controller.text.length >= 3) {
                                searchStories(_controller.text);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Hikaye ara...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          )
                          : results.isEmpty
                          ? const Center(
                            child: Text(
                              "Sonuç bulunamadı.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.separated(
                            itemCount: results.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final story = results[index];
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
                                child: Card(
                                  color: const Color(
                                    0xFF241537,
                                  ).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      story['title'] ?? 'Başlıksız',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      story['category'] ?? 'Kategori Yok',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
