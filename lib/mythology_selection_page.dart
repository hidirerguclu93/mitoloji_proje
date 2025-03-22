import 'package:flutter/material.dart';
import 'story_list_page.dart';

class MythologySelectionPage extends StatelessWidget {
  const MythologySelectionPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> mythologies = const [
    {"name": "Yunan", "icon": "⚡", "color": Colors.blue},
    {"name": "Mısır", "icon": "☀️", "color": Colors.orange},
    {"name": "Norse", "icon": "🌲", "color": Colors.green},
    {"name": "Hint", "icon": "🕉️", "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mitoloji Seç")),
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center, // Baloncukları ortala
          children: mythologies.map((mythology) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryListPage(mitoloji: mythology["name"] as String),
                  ),
                );
              },
              child: BubbleWidget(
                text: mythology["icon"] as String,
                color: mythology["color"] as Color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BubbleWidget extends StatelessWidget {
  final String text;
  final Color color;

  const BubbleWidget({Key? key, required this.text, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Sabit genişlik
      height: 80, // Sabit yükseklik (tam daire)
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
