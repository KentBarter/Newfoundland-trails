import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/log.dart';

class LogController {
  final User user;
  late final CollectionReference logs;

  LogController(this.user) {
    logs = FirebaseFirestore.instance.collection("users").doc(user.uid).collection("my_completed_hikes");
  }

  // uploading a image to google cloud storage and getting its url to be saved in the post for retrival
  Future<String> uploadImage(File imageFile) async {
    // the datetime will serve as each posts id
    final filename = "users/${user.uid}/hike_photos/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storageRef = FirebaseStorage.instance.ref().child(filename);
    final uploadTask = await storageRef.putFile(imageFile);

    // getting the url for storage
    return await uploadTask.ref.getDownloadURL();
  }

  // adding a log
  Future<void> addLog({
    required DateTime dateCompleted,
    required String trailName,
    required String description,
    required int rating,
    required File imageFile,
  }) async {
    // uploading the url
    final imageUrl = await uploadImage(imageFile);

    final docRef = logs.doc();

    // using log model
    final log = Log(
      id: docRef.id,
      dateCompleted: dateCompleted,
      trailName: trailName.trim(),
      description: description.trim(),
      rating: rating,
      imageUrl: imageUrl,
    );

    // saving the document
     await docRef.set(log.toMap());
  }

  // updating a log
  Future<void> updateLog({
    required Log log,
    required DateTime dateCompleted,
    required String trailName,
    required String description,
    required int rating,
    File? newImageFile,
  }) async {

    final docRef = logs.doc(log.id);
    final docSnap = await logs.doc(log.id).get();
    
    if (!docSnap.exists) {
      throw Exception("Log with ID ${log.id} does not exist.");
    }

    String? imageUrl = log.imageUrl;

    imageUrl = log.imageUrl;

    // If a new image is provided, upload it and delete the old one
    if (newImageFile != null) {
      final oldImageUrl = log.imageUrl;
      imageUrl = await uploadImage(newImageFile);

      if (oldImageUrl.isNotEmpty) {
        try {
          final oldref = FirebaseStorage.instance.refFromURL(oldImageUrl);
          await oldref.delete();
        } catch (e) {
          print("Error deleting old image: $e");
        }
      }
    }

    final finalImage = await uploadImage(newImageFile!);

    final updatedLog = Log(
      id: log.id,
      dateCompleted: dateCompleted,
      trailName: trailName.trim(),
      description: description.trim(),
      rating: rating,
      imageUrl: finalImage,
    );

    await docRef.update(updatedLog.toMap());
  }

  // deleting a log
  Future<void> deleteLog (Log log) async {
    final docRef = logs.doc(log.id);

    if (log.imageUrl.isNotEmpty){
      try {
        final ref = FirebaseStorage.instance.refFromURL(log.imageUrl);
        await ref.delete();
      } catch (e){
        print("Error deleting image: $e");
      }
    }

    // deleting document
    await docRef.delete();
  }
}