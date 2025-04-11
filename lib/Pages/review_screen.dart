import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allReviews;

  const ReviewsScreen({super.key, required this.allReviews});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: widget.allReviews.isEmpty
          ? const Center(
              child: Text(
                'No reviews available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: widget.allReviews.length,
              itemBuilder: (context, index) {
                final review = widget.allReviews[index];
                final reviewText = review['review'] ?? 'No review provided';
                final rating = review['rating'] ?? 0.0;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      reviewText,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      'Rating: $rating',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
