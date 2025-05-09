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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hikaye başarıyla eklendi")));
      titleController.clear();
      contentController.clear();
      imageUrlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amberAccent),
      filled: true,
      fillColor: Color(0xFF1A1325),
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
                DropdownMenuItem(value: 'chronological', child: Text('Hikaye')),
                DropdownMenuItem(value: 'character', child: Text('Karakter')),
              ],
              onChanged: (val) => setState(() => type = val as String),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration('Görsel URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              child: const Text('Hikaye Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
