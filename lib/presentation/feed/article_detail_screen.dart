import 'package:flutter/material.dart';
import 'package:myapp/models/article.dart';
import 'package:url_launcher/url_launcher.dart'; // add to pubspec.yaml


class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.sourceName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              Image.network(article.urlToImage),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Published: ${article.publishedAt.toLocal()}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(article.description),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(article.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Read Full Article'),
            ),
          ],
        ),
      ),
    );
  }
}