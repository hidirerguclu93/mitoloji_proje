import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryListPage extends StatefulWidget {
  final String mitoloji;

  const StoryListPage({super.key, required this.mitoloji});

  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> stories = [];

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    try {
      final response = await supabase
          .from('mythology_stories')
          .select()
          .eq('category', widget.mitoloji);

      if (response == null || response.isEmpty) {
        setState(() {
          stories = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bu mitoloji için henüz hikaye yok!"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        stories = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print("Hata oluştu: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hikayeler yüklenirken bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.mitoloji} Mitolojisi")),
      body: stories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Henüz hiç hikaye yok!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      story['title'] ?? "Başlık Yok",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        story['content'] ?? "İçerik Yok",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
            Icon(Icons.book, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(story['title'], overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story['title'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.black),
            SizedBox(height: 10),
            Text(
              story['content'],
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
