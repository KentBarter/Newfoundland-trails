import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'single_trail_view.dart';

class TrailsPageView extends StatefulWidget {
  const TrailsPageView({super.key});

  @override
  State<TrailsPageView> createState() => TrailsPageViewState();
}

// for sorting
enum SortOption { nosort, difficulty, length, estimatedTime}

// the trail view state
class TrailCard extends StatefulWidget{
  final String name;
  final String location;
  final String difficulty;
  final String length;
  final String estimatedCompletiontime;
  final String previewDescription;
  final String description;
  final String previewImageUrl;
  final String imageUrl;
  final double locationLat;
  final double locationLong;

  const TrailCard({
    Key? key,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.length,
    required this.estimatedCompletiontime,
    required this.previewDescription,
    required this.description,
    required this.previewImageUrl,
    required this.imageUrl,
    required this.locationLat,
    required this.locationLong,
  }) : super(key: key);

  @override
  State<TrailCard> createState() => TrailCardState();
}

class TrailCardState extends State<TrailCard> {
  late Future<String> imageFuture;

  @override
  void initState() {
    super.initState();
    imageFuture = getImageUrl(widget.previewImageUrl);
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

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => SingleTrailView(
            name: widget.name, 
            location: widget.location, 
            difficulty: widget.difficulty,
            length: widget.length, 
            estimatedCompletiontime: widget.estimatedCompletiontime, 
            description: widget.description, 
            imageUrl: widget.imageUrl, 
            locationLat: widget.locationLat, 
            locationLong: widget.locationLong
          )
        ),
        );
      }, child: Card(
      elevation: 4,
      margin: const EdgeInsets.all(6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // The Image
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
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported)),
                );
              }
              
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                  finalUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              );
            
            }
          ),

          // Other preview things like the name, categorty, location, preview description
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 3),

                    // location
                    Text(
                      widget.location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.fitness_center),
                    const SizedBox(width: 4),
                    // Category
                    Text(
                      widget.difficulty,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.straighten),
                    const SizedBox(width: 4),
                    // Category
                    Text(
                      widget.length,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 4),
                    // Category
                    Text(
                      widget.estimatedCompletiontime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  widget.previewDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  )
                )

              ],
            )
          )
        ],
      )
      )
    );
  }
}

class TrailsPageViewState extends State<TrailsPageView> with SingleTickerProviderStateMixin {
  late final CollectionReference trails;
  SortOption sortOption = SortOption.nosort;

  @override
  void initState() {
    super.initState();
    trails = FirebaseFirestore.instance.collection('trails');
  }

  // build a query for each of the selections
  Query buildQuery() {
    switch (sortOption) {
      case SortOption.nosort:
        return trails;
      case SortOption.difficulty:
        return trails;
      case SortOption.length:
        return trails.orderBy("length", descending: false);
      case SortOption.estimatedTime:
        return trails.orderBy("estimatedCompletiontime", descending: false);
    }
  }
  
  int difficultyOrder(String? difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 1;
      case 'Moderate':
        return 2;
      case 'Difficult':
        return 3;
      default:
        return 99;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: DropdownButton<SortOption>(
              value: sortOption,
              isExpanded: true, // makes it full width
              icon: const Icon(Icons.sort),
              dropdownColor: Colors.white,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    sortOption = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: SortOption.nosort,
                  child: Text("No Sort"),
                ),
                DropdownMenuItem(
                  value: SortOption.difficulty,
                  child: Text("Difficulty"),
                ),
                DropdownMenuItem(
                  value: SortOption.length,
                  child: Text("Length"),
                ),
                DropdownMenuItem(
                  value: SortOption.estimatedTime,
                  child: Text("Estimated Time"),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                    return const Center(child: Text("No trails found"));
                }

                // Convert to list of maps
                final trailsList = docs.map((d) => d.data() as Map<String, dynamic>).toList();

                if (sortOption == SortOption.difficulty) {
                  trailsList.sort((a, b) {
                    final diffA = a["difficulty"] as String?;
                    final diffB = b["difficulty"] as String?;
                    return difficultyOrder(diffA)
                        .compareTo(difficultyOrder(diffB));
                  });
                }

                return ListView.builder(
                  itemCount: trailsList.length,
                  itemBuilder: (context, index) {
                    final data = trailsList[index];
                    return TrailCard(
                      name: data["name"], 
                      location: data["location"], 
                      difficulty: data["difficulty"], 
                      length: data["length"], 
                      estimatedCompletiontime: data["estimatedCompletiontime"], 
                      previewDescription: data["previewDescription"], 
                      description: data["description"], 
                      previewImageUrl: data["previewImage"], 
                      imageUrl: data["image"], 
                      locationLat: data["locationLat"], 
                      locationLong: data["locationLong"],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

