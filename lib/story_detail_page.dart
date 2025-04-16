import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({super.key, required this.story});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late List<String> pages;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLiked = false;
  int likeCount = 0;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    pages = splitContentIntoPages(
      widget.story['content'] ?? "",
      maxLength: 900,
    );
    _loadLikeStatus();
    _loadFavoriteStatus();
  }

  List<String> splitContentIntoPages(String content, {int maxLength = 1000}) {
    final words = content.split(' ');
    List<String> result = [];
    String current = '';

    for (var word in words) {
      if ((current + word).length > maxLength) {
        result.add(current.trim());
        current = '';
      }
      current += '$word ';
    }

    if (current.isNotEmpty) {
      result.add(current.trim());
    }

    return result;
  }

  Future<void> _loadLikeStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final storyId = widget.story['story_uuid'];
    if (storyId == null) return;

    try {
      final likeRes =
          await Supabase.instance.client
              .from('story_likes')
              .select('id')
              .eq('user_id', user.id)
              .eq('story_id', storyId)
              .limit(1)
              .maybeSingle();

      final countRes = await Supabase.instance.client
          .from('story_likes')
          .select('id')
          .eq('story_id', storyId);

      setState(() {
        isLiked = likeRes != null;
        likeCount = countRes.length;
      });
    } catch (e) {
      print('Like durumunu yüklerken hata: $e');
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final storyId = widget.story['story_uuid'];
    if (storyId == null) return;

    try {
      final favRes =
          await Supabase.instance.client
              .from('story_favorites')
              .select()
              .eq('user_id', user.id)
              .eq('story_id', storyId)
              .maybeSingle();

      setState(() {
        isFavorited = favRes != null;
      });
    } catch (e) {
      print('Favori durumu yüklenemedi: $e');
    }
  }

  Future<void> _toggleLike() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    final storyId = widget.story['story_uuid'];
    if (storyId == null || isLiked) return;

    try {
      await Supabase.instance.client.from('story_likes').insert({
        'user_id': user.id,
        'story_id': storyId,
      });

      setState(() {
        isLiked = true;
        likeCount += 1;
      });
    } catch (e) {
      print('Beğeni eklenemedi: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    final storyId = widget.story['story_uuid'];
    if (storyId == null) return;

    try {
      if (isFavorited) {
        await supabase
            .from('story_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('story_id', storyId);

        setState(() {
          isFavorited = false;
        });
      } else {
        await supabase.from('story_favorites').insert({
          'user_id': user.id,
          'story_id': storyId,
        });

        setState(() {
          isFavorited = true;
        });
      }
    } catch (e) {
      print('[Favori Güncelleme Hatası] $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favori işlemi sırasında bir hata oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void goToPreviousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextPage() {
    if (_currentPage < pages.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title'] ?? "Hikaye";

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            pages[index],
                            style: const TextStyle(fontSize: 18, height: 1.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Sayfa ${index + 1} / ${pages.length}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (index == pages.length - 1)
                        Row(
                          children: [
                            IconButton(
                              onPressed: _toggleLike,
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                            ),
                            Text('$likeCount beğeni'),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                isFavorited ? Icons.star : Icons.star_border,
                                color: isFavorited ? Colors.amber : Colors.grey,
                              ),
                            ),
                            const Text('Favori'),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: _currentPage > 0 ? Colors.black : Colors.grey,
                  onPressed: _currentPage > 0 ? goToPreviousPage : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color:
                      _currentPage < pages.length - 1
                          ? Colors.black
                          : Colors.grey,
                  onPressed:
                      _currentPage < pages.length - 1 ? goToNextPage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
