import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/log_controller.dart';
import '../models/log.dart';

class AddEditView extends StatefulWidget {
  final Log? log;
  final LogController logController;

  const AddEditView({
    Key? key,
    this.log,
    required this.logController,
  }) : super(key: key);

  @override
  AddEditViewState createState() => AddEditViewState();
}

class AddEditViewState extends State<AddEditView> {
  final _formKey = GlobalKey<FormState>();
  List<String> trailNamesList = [];
  List<DropdownMenuItem<String>> _dropdownItems = [];

  DateTime dateCompleted = DateTime.now();
  String trailName = "";
  String description = "";
  int rating = 0;

  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTrailNames();
    if (widget.log != null) {
      // pre-fill for edit
      trailName = widget.log!.trailName;
      dateCompleted = widget.log!.dateCompleted;
      description = widget.log!.description;
      rating = widget.log!.rating;
    }
  }

  Future<void> _loadTrailNames() async {
    final snapshot = await FirebaseFirestore.instance.collection("trails").get();
    final trails = snapshot.docs
        .map((doc) => doc.data()["name"] as String? ?? "")
        .where((name) => name.isNotEmpty)
        .toList();

    setState(() {
      trailNamesList = trails;
      _dropdownItems = trails
          .map((trail) => DropdownMenuItem<String>(
                value: trail,
                child: Text(trail),
              ))
          .toList();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dateCompleted,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        dateCompleted = selectedDate;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      
      // handling if the file is too large
      final file = File(pickedFile.path);
      final bytes = await file.length();
      final maxImageSize = 5 * 1024 * 1024;

      // size check
      if (bytes > maxImageSize){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image is too large"))
        );
        return;
      }

      // file type check
      final allowedExtensions = ["jpg"];
      final extension = pickedFile.path.split(".").last.toLowerCase();
      if (!allowedExtensions.contains(extension)){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not a valid Image type"))
        );
        return;
      }

      setState(() {
        imageFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log == null ? "Add Trail Log" : "Edit Trail Log"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Trail dropdown
              DropdownButtonFormField<String>(
                value: trailName.isNotEmpty ? trailName : null,
                items: _dropdownItems,
                hint: const Text("Select a trail"),
                onChanged: (value) {
                  setState(() {
                    trailName = value!;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? "Please select a trail" : null,
              ),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: "Diary Entry Date"),
                    controller: TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(dateCompleted)),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rating
              RatingBar.builder(
                initialRating: rating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.blue,
                ),
                onRatingUpdate: (r) {
                  rating = r.toInt();
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                initialValue: description,
                maxLength: 200,
                decoration: const InputDecoration(labelText: "Enter your Notes"),
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 16),

              // Image picker
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text("Select Image"),
              ),
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.file(imageFile!, height: 150),
                ),
              const SizedBox(height: 16),

              // Add/Edit button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (widget.log == null) {
                      await widget.logController.addLog(trailName: trailName, dateCompleted: dateCompleted, description: description, rating: rating, imageFile: imageFile!);
                    } else {
                      print(widget.log!.id);
                      await widget.logController.updateLog(log: widget.log!, trailName: trailName, dateCompleted: dateCompleted, description: description, rating: rating, newImageFile: imageFile!);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.log == null ? "Add Log" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
