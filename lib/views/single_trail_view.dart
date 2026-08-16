import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SingleTrailView extends StatefulWidget {
  final String name;
  final String location;
  final String difficulty;
  final String length;
  final String estimatedCompletiontime;
  final String description;
  final String imageUrl;
  final double locationLat;
  final double locationLong;

  const SingleTrailView({
    super.key,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.length,
    required this.estimatedCompletiontime,
    required this.description,
    required this.imageUrl,
    required this.locationLat,
    required this.locationLong,
  });

  @override
  State<SingleTrailView> createState() => SingleTrailViewState();
}

class SingleTrailViewState extends State<SingleTrailView> {
  late Future<String> imageFuture;

  @override
  void initState() {
    super.initState();
    imageFuture = getImageUrl(widget.imageUrl);
  }

  // getting the fixec url from firebase could storage and generating a http url to retrive the photo
  Future<String> getImageUrl(String url) async {
    if (url.startsWith('http')) return url;
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting image URL for $url: $e');
      rethrow;
    }
  }

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            FutureBuilder(
                future: imageFuture,
                builder: (context, snapshot) {
                  // check for loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  // checking for error or missing data
                  final finalUrl = snapshot.data!;
                  if (snapshot.hasError || finalUrl.isEmpty) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image_not_supported)),
                    );
                  }
                  
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                      finalUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                  ),
                );
              }
            ),

            // location
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 4),

                // location
                Text(
                  widget.location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Difficulty
                Text(
                  widget.difficulty,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            // location
            const SizedBox(height: 10),
            
            // time
            Row(
              children: [
                const Icon(Icons.straighten),
                const SizedBox(width: 4),

                // location
                Text(
                  widget.length,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // cost
            Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 4),

                // location
                Text(
                  widget.estimatedCompletiontime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // description
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              )
            )

          ],
        )
      )
    );
  }
}