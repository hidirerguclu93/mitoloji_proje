import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'story_detail_page.dart';
import 'login_page.dart'; // LoginPage yönlendirmesi için eklendi

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  User? user;

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
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final favResponse = await supabase
          .from('story_favorites')
          .select('story_id')
          .eq('user_id', user!.id);

      final favList =
          (favResponse as List).map((e) => e['story_id'] as String).toList();

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

  @override
  Widget build(BuildContext context) {
    final username =
        (user?.userMetadata?['username'] as String?) ??
        user?.email ??
        'Misafir Kullanıcı';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5ACD), Color(0xFF191970)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : favorites.isEmpty
                          ? const Center(
                            child: Text(
                              'Henüz favori eklemediniz.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              itemCount: favorites.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                              itemBuilder: (context, index) {
                                final story = favorites[index];
                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                StoryDetailPage(story: story),
                                      ),
                                    );
                                    _fetchFavorites();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.1),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          story['image_url'] != null
                                              ? Image.network(
                                                story['image_url'],
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                              )
                                              : Container(
                                                color: Colors.grey.shade300,
                                              ),
                                          Container(
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                story['title'] ?? 'Başlık Yok',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
