import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mythology_category_page.dart';

class MythologySelectionPage extends StatelessWidget {
  const MythologySelectionPage({super.key});

  final List<Map<String, dynamic>> mythologies = const [
    {"name": "Yunan", "image": "assets/icons/zeus.png"},
    {"name": "Mısır", "image": "assets/icons/eye-of-horus.png"},
    {"name": "İskandinav", "image": "assets/icons/odin.png"},
    {"name": "Türk", "image": "assets/icons/wolf.png"},
    {"name": "Japon", "image": "assets/icons/amaterasu.png"},
    {"name": "Hint", "image": "assets/icons/ganesha.png"},
    {"name": "Çin", "image": "assets/icons/chinese.png"},
    {"name": "Aztek", "image": "assets/icons/aztek.png"},
    {"name": "Yerli", "image": "assets/icons/eagle.png"},
    {"name": "Slav", "image": "assets/icons/slav_bear.png"},
    {"name": "Kelt", "image": "assets/icons/kelt_mit.png"},
    {"name": "Roma", "image": "assets/icons/roma.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Mitolojini Seç"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/mozabackg.webp", fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF241537).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFA36D3D).withOpacity(0.7),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children:
                      mythologies.map((myth) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MythologyCategoryPage(
                                      selectedMythology: myth["name"],
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(myth["image"] as String),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                myth["name"] as String,
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amberAccent,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black87,
                                      offset: Offset(0.5, 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
