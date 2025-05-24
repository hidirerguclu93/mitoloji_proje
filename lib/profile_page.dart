import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'story_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  User? user;
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  int likeCount = 0;
  int favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  Future<void> _checkSessionAndFetch() async {
    final session = supabase.auth.currentSession;
    if (session == null || session.user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }
    setState(() => user = session.user);
    await Future.wait([_fetchFavorites(), _fetchStats()]);
  }

  Future<void> _fetchFavorites() async {
    try {
      final favResponse = await supabase
          .from('story_favorites')
          .select('story_uuid')
          .eq('user_id', user!.id);

      final favList =
          (favResponse as List).map((e) => e['story_uuid'] as String).toList();

      if (favList.isEmpty) {
        setState(() {
          favorites = [];
          isLoading = false;
        });
        return;
      }

      final storyResponse = await supabase
          .from('mythology_stories')
          .select('title, image_url, content, story_uuid')
          .filter(
            'story_uuid',
            'in',
            '(${favList.map((id) => '"$id"').join(',')})',
          );

      final storyList = List<Map<String, dynamic>>.from(storyResponse as List);
      setState(() {
        favorites = storyList;
        isLoading = false;
      });
    } catch (error) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Favoriler alınamadı: $error')));
      }
    }
  }

  Future<void> _fetchStats() async {
    try {
      final likes = await supabase
          .from('story_likes')
          .select('id')
          .eq('user_id', user!.id);
      final favorites = await supabase
          .from('story_favorites')
          .select('id')
          .eq('user_id', user!.id);

      setState(() {
        likeCount = (likes as List).length;
        favoriteCount = (favorites as List).length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("İstatistikler alınamadı: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'Misafir Kullanıcı';

    return Scaffold(
      backgroundColor: const Color(0xFF0D090A),
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5ACD), Color(0xFF191970)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatCard(Icons.favorite, likeCount),
                    const SizedBox(width: 24),
                    _buildStatCard(Icons.star, favoriteCount),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : favorites.isEmpty
                    ? const Center(
                      child: Text(
                        'Henüz favori eklemediniz.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final story = favorites[index];
                        return Card(
                          color: const Color(0xFF1A1325),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              story['title'] ?? 'Başlık Yok',
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          "Favorilerden kaldırılsın mı?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Hayır"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Evet"),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  final storyId = story['story_uuid'];
                                  final userId = user?.id;
                                  if (storyId != null && userId != null) {
                                    await supabase
                                        .from('story_favorites')
                                        .delete()
                                        .eq('user_id', userId)
                                        .eq('story_uuid', storyId);

                                    await Future.wait([
                                      _fetchFavorites(),
                                      _fetchStats(),
                                    ]);
                                    setState(() {});

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Favorilerden kaldırıldı.",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryDetailPage(story: story),
                                ),
                              );
                              if (result == true) {
                                await Future.wait([
                                  _fetchFavorites(),
                                  _fetchStats(),
                                ]);
                                setState(() {});
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, int count) {
    return Column(
      children: [
        Icon(icon, color: Colors.amberAccent),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
