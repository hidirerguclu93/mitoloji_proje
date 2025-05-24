import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  String category = 'Yunan';
  String type = 'chronological';

  bool showForm = false;
  bool showStoryList = false;
  List<Map<String, dynamic>> stories = [];

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    final data = await Supabase.instance.client
        .from('mythology_stories')
        .select('*')
        .order('created_at', ascending: false);
    setState(() => stories = List<Map<String, dynamic>>.from(data));
  }

  Future<void> submitStory() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kullanıcı bulunamadı")));
      return;
    }

    final data = {
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'category': category,
      'type': type,
      'image_url': imageUrlController.text.trim(),
      'author_id': user.id,
    };

    try {
      await supabase.from('mythology_stories').insert(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Metin başarıyla kaydedildi")),
      );
      titleController.clear();
      contentController.clear();
      imageUrlController.clear();
      fetchStories();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Future<void> updateStory(String uuid) async {
    final supabase = Supabase.instance.client;

    final updates = {
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'category': category,
      'type': type,
      'image_url': imageUrlController.text.trim(),
    };

    try {
      await supabase
          .from('mythology_stories')
          .update(updates)
          .eq('story_uuid', uuid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Metin başarıyla güncellendi")),
      );
      fetchStories();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Future<void> deleteStory(String uuid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Silme Onayı"),
            content: const Text("Bu metni silmek istediğinize emin misiniz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("İptal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Sil"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await Supabase.instance.client
          .from('mythology_stories')
          .delete()
          .eq('story_uuid', uuid);
      fetchStories();
    }
  }

  void openEditBottomSheet(Map<String, dynamic> story) {
    titleController.text = story['title'] ?? '';
    contentController.text = story['content'] ?? '';
    imageUrlController.text = story['image_url'] ?? '';
    category = story['category'] ?? 'Yunan';
    type = story['type'] ?? 'chronological';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1325),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('Başlık'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('İçerik'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('Görsel URL'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: category,
                  dropdownColor: const Color(0xFF1A1325),
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'Yunan', child: Text('Yunan')),
                    DropdownMenuItem(value: 'Mısır', child: Text('Mısır')),
                    DropdownMenuItem(
                      value: 'İskandinav',
                      child: Text('İskandinav'),
                    ),
                    DropdownMenuItem(value: 'Türk', child: Text('Türk')),
                    DropdownMenuItem(value: 'Japon', child: Text('Japon')),
                    DropdownMenuItem(value: 'Hint', child: Text('Hint')),
                    DropdownMenuItem(value: 'Çin', child: Text('Çin')),
                    DropdownMenuItem(value: 'Aztek', child: Text('Aztek')),
                    DropdownMenuItem(value: 'Yerli', child: Text('Yerli')),
                    DropdownMenuItem(value: 'Slav', child: Text('Slav')),
                    DropdownMenuItem(value: 'Kelt', child: Text('Kelt')),
                    DropdownMenuItem(value: 'Roma', child: Text('Roma')),
                  ],
                  onChanged: (val) => setState(() => category = val as String),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: type,
                  dropdownColor: const Color(0xFF1A1325),
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('Tür'),
                  items: const [
                    DropdownMenuItem(
                      value: 'chronological',
                      child: Text('Hikaye'),
                    ),
                    DropdownMenuItem(
                      value: 'character',
                      child: Text('Karakter'),
                    ),
                  ],
                  onChanged: (val) => setState(() => type = val as String),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await updateStory(story['story_uuid']);
                    Navigator.pop(context);
                    fetchStories();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Kaydet"),
                ),
              ],
            ),
          ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amberAccent),
      filled: true,
      fillColor: const Color(0xFF0D090A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.amberAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF241537),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0D090A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => setState(() => showForm = !showForm),
              child: Text(showForm ? 'Formu Gizle' : 'Yeni Metin Ekle'),
            ),
            const SizedBox(height: 12),
            if (showForm)
              Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration('Başlık'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration('İçerik'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration('Görsel URL'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: category,
                    dropdownColor: const Color(0xFF1A1325),
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration('Kategori'),
                    items: const [
                      DropdownMenuItem(value: 'Yunan', child: Text('Yunan')),
                      DropdownMenuItem(value: 'Mısır', child: Text('Mısır')),
                      DropdownMenuItem(
                        value: 'İskandinav',
                        child: Text('İskandinav'),
                      ),
                      DropdownMenuItem(value: 'Türk', child: Text('Türk')),
                      DropdownMenuItem(value: 'Japon', child: Text('Japon')),
                      DropdownMenuItem(value: 'Hint', child: Text('Hint')),
                      DropdownMenuItem(value: 'Çin', child: Text('Çin')),
                      DropdownMenuItem(value: 'Aztek', child: Text('Aztek')),
                      DropdownMenuItem(value: 'Yerli', child: Text('Yerli')),
                      DropdownMenuItem(value: 'Slav', child: Text('Slav')),
                      DropdownMenuItem(value: 'Kelt', child: Text('Kelt')),
                      DropdownMenuItem(value: 'Roma', child: Text('Roma')),
                    ],
                    onChanged:
                        (val) => setState(() => category = val as String),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: type,
                    dropdownColor: const Color(0xFF1A1325),
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration('Tür'),
                    items: const [
                      DropdownMenuItem(
                        value: 'chronological',
                        child: Text('Hikaye'),
                      ),
                      DropdownMenuItem(
                        value: 'character',
                        child: Text('Karakter'),
                      ),
                    ],
                    onChanged: (val) => setState(() => type = val as String),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: submitStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Metni Kaydet"),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => setState(() => showStoryList = !showStoryList),
              child: Text(
                showStoryList ? 'Metinleri Gizle' : 'Eklenen Metinleri Göster',
              ),
            ),
            const SizedBox(height: 12),
            if (showStoryList)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return Card(
                    color: const Color(0xFF1A1325),
                    child: ListTile(
                      title: Text(
                        story['title'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${story['category']} - ${(story['created_at'] ?? '').toString().split("T")[0]}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () => openEditBottomSheet(story),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteStory(story['story_uuid']),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
