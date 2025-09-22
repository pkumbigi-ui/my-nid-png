import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:url_launcher/url_launcher.dart';

/// Model for News Article
class NewsArticle {
  final String title;
  final String link;
  final String description;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
  });
}

/// Service to fetch RSS feed from Post-Courier
class NewsService {
  final String feedUrl = "https://postcourier.com.pg/feed/";

  Future<List<NewsArticle>> fetchNews() async {
    final response = await http.get(Uri.parse(feedUrl));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.map((node) {
        final title = node.findElements('title').single.text;
        final link = node.findElements('link').single.text;
        final description = node.findElements('description').isNotEmpty
            ? node.findElements('description').single.text
            : "";

        // Extract image if available inside <media:content> or description
        String imageUrl = "";
        final media = node.findElements('media:content');
        if (media.isNotEmpty) {
          imageUrl = media.first.getAttribute('url') ?? "";
        }

        return NewsArticle(
          title: title,
          link: link,
          description: description,
          imageUrl: imageUrl,
        );
      }).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}

/// Widget to display News in card format
class NewsCardSection extends StatefulWidget {
  const NewsCardSection({super.key});

  @override
  State<NewsCardSection> createState() => _NewsCardSectionState();
}

class _NewsCardSectionState extends State<NewsCardSection> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final articles = await _newsService.fetchNews();
      setState(() {
        _articles = articles.take(6).toList(); // show first 6 news items
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Error fetching news: $e");
    }
  }

  Future<void> _openHomePage() async {
    final uri = Uri.parse("https://www.postcourier.com.pg/");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_articles.isEmpty) return const Text("No news available");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📰 Latest News (Post-Courier)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Display News in Grid Format
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            childAspectRatio: 1, // square-like cards
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final article = _articles[index];
            return GestureDetector(
              onTap: _openHomePage, // Redirect always to homepage
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail image
                    if (article.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Image.network(
                          article.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                        ),
                        child: const Icon(Icons.image, size: 40),
                      ),

                    // Title + Description
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        article.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        // Button to Post-Courier Home
        ElevatedButton(
          onPressed: _openHomePage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("View All News"),
        ),
      ],
    );
  }
}
