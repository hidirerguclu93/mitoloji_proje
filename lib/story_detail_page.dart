import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final supabase = Supabase.instance.client;
  final PageController _pageController = PageController();

  late List<String> pages;
  int _currentPage = 0;
  bool isLiked = false;
  bool isFavorited = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    pages = _splitContent(widget.story['content'] ?? '');
    _loadLikeStatus();
    _loadFavoriteStatus();
  }

  List<String> _splitContent(String content, {int maxLength = 900}) {
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
    if (current.isNotEmpty) result.add(current.trim());
    return result;
  }

  Future<void> _loadLikeStatus() async {
    final user = supabase.auth.currentUser;
    final storyId = widget.story['story_uuid'];
    if (user == null || storyId == null) return;

    try {
      final likeRes =
          await supabase
              .from('story_likes')
              .select('id')
              .eq('user_id', user.id)
              .eq('story_id', storyId)
              .maybeSingle();

      final countRes = await supabase
          .from('story_likes')
          .select('id')
          .eq('story_id', storyId);

      setState(() {
        isLiked = likeRes != null;
        likeCount = (countRes as List).length;
      });
    } catch (_) {}
  }

  Future<void> _loadFavoriteStatus() async {
    final user = supabase.auth.currentUser;
    final storyId = widget.story['story_uuid'];
    if (user == null || storyId == null) return;

    try {
      final favRes =
          await supabase
              .from('story_favorites')
              .select('id')
              .eq('user_id', user.id)
              .eq('story_id', storyId)
              .maybeSingle();

      setState(() {
        isFavorited = favRes != null;
      });
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    final user = supabase.auth.currentUser;
    final storyId = widget.story['story_uuid'];
    if (user == null || storyId == null) return;

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      if (isLiked) {
        await supabase.from('story_likes').insert({
          'user_id': user.id,
          'story_id': storyId,
        });
      } else {
        await supabase
            .from('story_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('story_id', storyId);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    final storyId = widget.story['story_uuid'];
    if (user == null || storyId == null) return;

    setState(() {
      isFavorited = !isFavorited;
    });

    try {
      if (isFavorited) {
        await supabase.from('story_favorites').insert({
          'user_id': user.id,
          'story_id': storyId,
        });
      } else {
        await supabase
            .from('story_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('story_id', storyId);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title'] ?? 'Hikaye';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A5ACD), Color(0xFF191970)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0) ...[
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      pages[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Sayfa ${index + 1} / ${pages.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_currentPage == pages.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.redAccent : Colors.white,
                        ),
                      ),
                      Text(
                        '$likeCount',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorited ? Icons.star : Icons.star_border,
                          color:
                              isFavorited ? Colors.amberAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
