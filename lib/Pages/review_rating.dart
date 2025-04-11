import 'package:VolunteeringApp/DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/VolunteeringHistory.dart';

class ReviewAndRating extends StatefulWidget {
  final String? eventId;
  final String? organiserId;
  final String? eventName;
  final String? organiserName;

  const ReviewAndRating({
    super.key,
    this.eventId,
    this.organiserId,
    this.eventName,
    this.organiserName,
  });

  @override
  State<ReviewAndRating> createState() => _ReviewAndRatingState();
}

class _ReviewAndRatingState extends State<ReviewAndRating> {
  final _reviewController = TextEditingController();
  double _rating = 0;
  bool _isLoading = true; // To manage loading state
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String existingDocId = "";
  List<VolunteeringHistory> workHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.eventId == null && widget.organiserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Either event or organiser should be reviewed."),
        ));
        Navigator.pop(context); // Automatically close the screen
      });
    }
    _fetchWorkRecord();
    _fetchExistingReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventId == null && widget.organiserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(
          child: Text(
            "Invalid configuration: Missing event or organiser information.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Review your work experience",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.eventName != null)
                    Text(
                      "Event: ${widget.eventName}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (workHistory.isNotEmpty)
                    Flexible(child: buildWorkRecord()),
                  if (widget.organiserName != null)
                    Text(
                      "Organiser: ${widget.organiserName}",
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  Text(
                    "Rate your experience:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Flexible(
                    child: Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color:
                                index < _rating ? Colors.orange : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your Review:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Flexible(
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Write about your experience...",
                      ),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle submission logic
                      String review = _reviewController.text;
                      if (_rating > 0 && review.isNotEmpty) {
                        // Submit the review and rating
                        await provideReview(_rating, review, userId,
                            eventId: widget.eventId,
                            organisationId: widget.organiserId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Review submitted successfully!"),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Please provide both rating and review."),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Center(
                      child: Text(
                        "${existingDocId.isNotEmpty ? 'Update' : 'Submit'} Review",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _fetchExistingReview() async {
    if (widget.organiserId == null && widget.eventId == null) {
      return;
    }

    try {
      // Query Firestore to fetch the existing review
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId',
              isEqualTo: userId) // Replace with logged-in user's ID
          .where('organisationId', isEqualTo: widget.organiserId)
          .where('eventId', isEqualTo: widget.eventId)
          .limit(1)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        // Populate the fields if a review exists
        final reviewData =
            reviewSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          existingDocId = reviewSnapshot.docs.first.id;
          _reviewController.text = reviewData['review'];
          _rating = reviewData['rating'] ?? 0.0;
        });
      }
    } catch (e) {
      print("Failed to fetch review: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> provideReview(double rating, String review, String userId,
      {String? organisationId, String? eventId}) async {
    if (organisationId == null && eventId == null) {
      print("Error: Either organisationId or eventId must be provided.");
      return;
    }

    try {
      // Reference to the Firestore collection
      final reviewsCollection =
          FirebaseFirestore.instance.collection('reviews');
      // Prepare the document data
      final reviewData = {
        'rating': rating,
        'review': review,
        'userId': userId,
        'organisationId': organisationId,
        'eventId': eventId,
        'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
      };

      if (existingDocId.isNotEmpty) {
        // Update the existing review document
        await reviewsCollection.doc(existingDocId).update(reviewData);
      } else {
        // Add the review document to Firestore
        await reviewsCollection.add(reviewData);
      }
    } catch (e) {
      print("Failed to submit review: $e");
    }
  }

  void _fetchWorkRecord() async {
    if (widget.eventId == null) {
      return;
    }
    workHistory = await VolunteeringHistoryDAO.getHistoryByEventAndUser(
        widget.eventId!, userId);
    setState(() {});
  }

  Widget buildWorkRecord() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5)
      ),      
      child: ListView.builder(
        itemCount: workHistory.length,
        itemBuilder: (context, index) {
          final record = workHistory[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Role: ${record.role}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Task: ${record.task}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: ${record.date.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Time Spent: ${record.hours} hours ${record.minutes} minutes",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
