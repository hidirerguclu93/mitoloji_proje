import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    pages = splitContentIntoPages(
      widget.story['content'] ?? "",
      maxLength: 900,
    );
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
