import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_edit_view.dart';
import '../controllers/log_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/log.dart';

class LogViewIn extends StatefulWidget {
  const LogViewIn({super.key});

  @override
  State<LogViewIn> createState() => LogViewInState();
}

// Log card custom widget to display all information including the photo
class LogCard extends StatefulWidget {
  final LogController controller;
  final String id;
  final Timestamp dateCompleted;
  final String trailName;
  final String description;
  final int rating;
  final String imageUrl;

  const LogCard({
    Key? key,
    required this.controller,
    required this.id,
    required this.dateCompleted,
    required this.trailName,
    required this.description,
    required this.rating,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<LogCard> createState() => LogCardState();
}

class LogCardState extends State<LogCard> {

  // Getting the download URL from Firebase Storage
  Future<String> getImageUrl(String url) async {
    if (url.startsWith('http')) {
      return url;
    }

    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting image URL for $url: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: getImageUrl(widget.imageUrl),
            builder: (context, snapshot) {

              // Loading
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Error / missing image
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                );
              }

              // Display image
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  snapshot.data!,
                  key: ValueKey(widget.imageUrl),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Trail name and completion date
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Expanded(
                      child: Text(
                        widget.trailName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      DateFormat('dd-MM-yyyy')
                          .format(widget.dateCompleted.toDate()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Center(
                  child: RatingBarIndicator(
                    rating: widget.rating.toDouble(),
                    itemBuilder: (context, index) =>
                        const Icon(
                      Icons.star,
                      color: Colors.blue,
                    ),
                    itemCount: 5,
                    itemSize: 25.0,
                    direction: Axis.horizontal,
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // EDIT
                    ElevatedButton(
                      onPressed: () {

                        final log = Log(
                          id: widget.id,
                          dateCompleted:
                              widget.dateCompleted.toDate(),
                          trailName: widget.trailName,
                          description: widget.description,
                          rating: widget.rating,
                          imageUrl: widget.imageUrl,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditView(
                              logController: widget.controller,
                              log: log,
                            ),
                          ),
                        );
                      },
                      child: const Text("Edit Log"),
                    ),

                    const SizedBox(width: 10),

                    // DELETE
                    ElevatedButton(
                      onPressed: () {

                        final log = Log(
                          id: widget.id,
                          dateCompleted:
                              widget.dateCompleted.toDate(),
                          trailName: widget.trailName,
                          description: widget.description,
                          rating: widget.rating,
                          imageUrl: widget.imageUrl,
                        );

                        widget.controller.deleteLog(log);
                      },
                      child: const Text("Delete Log"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogViewInState extends State<LogViewIn>
    with SingleTickerProviderStateMixin {

  late final CollectionReference logs;
  User? user;
  late final LogController logController;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      logs = FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("my_completed_hikes");

      logController = LogController(user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trail Logs"),
        centerTitle: true,

        actions: [
          IconButton(
            tooltip: "Log out",
            onPressed: () =>
                FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditView(
                logController: logController,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: logs.snapshots(),

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          // Get documents
          final docs = snapshot.data?.docs ?? [];

          // No logs
          if (docs.isEmpty) {
            return const Center(
              child: Text("No trails found"),
            );
          }

          // Display logs
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              return LogCard(
                key: ValueKey(data.id),
                controller: logController,
                id: data["id"],
                dateCompleted: data["DateCompleted"],
                trailName: data["TrailName"],
                description: data["Description"],
                rating: data["Rating"],
                imageUrl: data["ImageUrl"],
              );
            },
          );
        },
      ),
    );
  }
}