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
  int fontSizeLevel = 1;

  double get currentFontSize {
    switch (fontSizeLevel) {
      case 0:
        return 16.0;
      case 2:
        return 24.0;
      default:
        return 20.0;
    }
  }

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
              .eq('story_uuid', storyId)
              .maybeSingle();

      final countRes = await supabase
          .from('story_likes')
          .select('id')
          .eq('story_uuid', storyId);

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
              .eq('story_uuid', storyId)
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
          'story_uuid': storyId,
        });
      } else {
        await supabase
            .from('story_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('story_uuid', storyId);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    final storyId = widget.story['story_uuid'];
    if (user == null || storyId == null) return;

    final wasFavorited = isFavorited;

    setState(() {
      isFavorited = !isFavorited;
    });

    try {
      if (isFavorited) {
        await supabase.from('story_favorites').insert({
          'user_id': user.id,
          'story_uuid': storyId,
        });
      } else {
        await supabase
            .from('story_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('story_uuid', storyId);

        if (wasFavorited && mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title'] ?? 'Hikaye';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, isFavorited ? false : true);
          },
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) => setState(() => fontSizeLevel = value),
            icon: const Icon(Icons.text_fields, color: Colors.white),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 0, child: Text('Küçük')),
                  PopupMenuItem(value: 1, child: Text('Normal')),
                  PopupMenuItem(value: 2, child: Text('Büyük')),
                ],
          ),
        ],
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
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pages.length,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged:
                            (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1A1325,
                                    ).withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFA36D3D,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (index == 0) ...[
                                        Center(
                                          child: Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFD700),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            pages[index],
                                            style: TextStyle(
                                              fontSize: currentFontSize,
                                              height: 1.6,
                                              color: const Color(0xFFE0E0E0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (_currentPage > 0)
                                            IconButton(
                                              onPressed: () {
                                                _pageController.previousPage(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.arrow_back_ios,
                                              ),
                                              color: Colors.white,
                                            ),
                                          Text(
                                            'Sayfa ${index + 1} / ${pages.length}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          if (_currentPage < pages.length - 1)
                                            IconButton(
                                              onPressed: () {
                                                _pageController.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.arrow_forward_ios,
                                              ),
                                              color: Colors.white,
                                            ),
                                        ],
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
                    const SizedBox(height: 12),
                    if (_currentPage == pages.length - 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _toggleLike,
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color:
                                  isLiked
                                      ? const Color(0xFFFF4D4D)
                                      : Colors.white,
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
                                  isFavorited
                                      ? const Color(0xFFFFD700)
                                      : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
