import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:raccoon_learning/presentation/admin/data/store/store_default_modle.dart';
import 'package:raccoon_learning/presentation/admin/data/store/store_default_repository.dart';
import 'package:raccoon_learning/presentation/admin/page/dash_board.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';


class StoreAdminPage extends StatefulWidget {
  const StoreAdminPage({super.key});

  @override
  _StoreAdminPageState createState() => _StoreAdminPageState();
}

class _StoreAdminPageState extends State<StoreAdminPage> {
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _imageBytes; // Store image bytes for web
  String? _imageUrl; // Store the URL of the uploaded image
  StoreDefaultRepository storeDefaultRepository = StoreDefaultRepository();

  @override
  void initState() {
    _initializeSupabase();
    super.initState();
  }

  Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://wgwzbsfxetgyropkgmkq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indnd3pic2Z4ZXRneXJvcGtnbWtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4ODIyNTgsImV4cCI6MjA1ODQ1ODI1OH0.1HhgTxBVIazqslaVmGKoFg8bBvYZEGSohpzvFo2S00E', 
    );
  }

  @override
  void dispose() {
    _priceController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }
  // Function to pick an image from the browser
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Restrict to image files
        allowMultiple: false, // Only one file allowed
        withData: true, // Get file bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytes = result.files.single.bytes; // Get image bytes
          _imageUrl = result.files.single.name;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

    // Function to upload the image to Supabase Storage
  Future<void> _uploadImageSupabass() async {
    if (_imageBytes == null) return;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unique file name

      // Upload image to 'image' bucket with explicit content type
      await Supabase.instance.client.storage.from('image').uploadBinary(
            fileName,
            _imageBytes!,
            fileOptions: const FileOptions(contentType: 'image/jpeg'), // Named parameter
          );

      // Get the public URL of the uploaded image
      final String publicUrl =
          Supabase.instance.client.storage.from('image').getPublicUrl(fileName);

      setState(() {
        _imageUrl = publicUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
      print('Uploaded image URL: $publicUrl');
    } on StorageException catch (e) {
      print('Storage error: ${e.message}, Status: ${e.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage error: ${e.message}')),
      );
    } catch (e) {
      print('Unexpected error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

    Future<void> _submitData() async {
    if (_imageUrl == null || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image and enter a price')),
      );
      return;
    }

    final int? price = int.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price format')),
      );
      return;
    }

    final storeDefaultModel = StoreDefaultModle(_imageUrl!, price);

    await storeDefaultRepository.uploadQuestionToFirebase(storeDefaultModel);
  }
    void _clearData() {
      setState(() {
        _priceController.clear();  // Clears text input field
        _imageUrl = "";            // Clears the image URL
        _imageBytes = null;        // Clears the image preview
      });
    }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(context), // Build the header with search bar and user info
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20), // Padding around the scrollable content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Store Item',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // Spacing between title and form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price input section
                      const Text(
                        'Price',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number, // Numeric keyboard for price
                        decoration: InputDecoration(
                          hintText: 'Enter price (e.g.,50)',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Add Image Button with file picker logic
                      ElevatedButton.icon(
                        onPressed: _pickImage, // Call the image picker method
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text('Add Image', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green..shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Display selected image path (optional, for feedback)
                      if (_imageUrl != null)
                        Text(
                          'Selected: ${_imageUrl!.split('/').last}', // Show file name
                          style: const TextStyle(color: Colors.black54),
                        ),
                      const SizedBox(height: 20),
                      // Submit Button
                      ElevatedButton(
                        onPressed: () async{
                          //push image to supabass to can store img online and save data to firebase
                         await _uploadImageSupabass();  
                         _submitData();
                         _clearData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}