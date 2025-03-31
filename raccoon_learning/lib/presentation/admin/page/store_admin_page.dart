import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:raccoon_learning/presentation/admin/data/store/store_default_modle.dart';
import 'package:raccoon_learning/presentation/admin/data/store/store_default_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreAdminPage extends StatefulWidget {
  const StoreAdminPage({super.key});

  @override
  _StoreAdminPageState createState() => _StoreAdminPageState();
}

class _StoreAdminPageState extends State<StoreAdminPage> {
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageUrl;
  final StoreDefaultRepository storeDefaultRepository = StoreDefaultRepository();
  List<StoreDefaultModle> _storeItems = []; // To hold fetched store items

  @override
  void initState() {
    _initializeSupabase();
    _fetchStoreItems(); // Fetch items when the page loads
    super.initState();
  }

  Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://wgwzbsfxetgyropkgmkq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indnd3pic2Z4ZXRneXJvcGtnbWtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4ODIyNTgsImV4cCI6MjA1ODQ1ODI1OH0.1HhgTxBVIazqslaVmGKoFg8bBvYZEGSohpzvFo2S00E',
    );
  }

  Future<void> _fetchStoreItems() async {
    try {
      final items = await storeDefaultRepository.getStoreDefault();
      setState(() {
        _storeItems = items;
      });
    } catch (e) {
      print('Error fetching store items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytes = result.files.single.bytes;
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

  Future<void> _uploadImageSupabass() async {
    if (_imageBytes == null) return;
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage.from('image').uploadBinary(
            fileName,
            _imageBytes!,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      final String publicUrl = Supabase.instance.client.storage.from('image').getPublicUrl(fileName);
      setState(() {
        _imageUrl = publicUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
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
    _fetchStoreItems(); // Refresh the list after adding
    _clearData();
  }

  void _clearData() {
    setState(() {
      _priceController.clear();
      _imageUrl = null;
      _imageBytes = null;
    });
  }

  Future<void> _updatePrice(String docId, int newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('store_default')
          .doc(docId)
          .update({'price': newPrice});
      _fetchStoreItems(); // Refresh the list after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price updated successfully')),
      );
    } catch (e) {
      print('Error updating price: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating price: $e')),
      );
    }
  }

  Future<void> _deleteItem(String docId, String imageUrl) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('store_default').doc(docId).delete();

      // Extract file name from URL and delete from Supabase
      final fileName = imageUrl.split('/').last;
      await Supabase.instance.client.storage.from('image').remove([fileName]);

      _fetchStoreItems(); // Refresh the list after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Assuming buildHeader is defined elsewhere
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),
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
                      const Text('Price', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter price (e.g., 50)',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text('Add Image', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_imageUrl != null)
                        Text('Selected: ${_imageUrl!.split('/').last}', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _uploadImageSupabass();
                          await _submitData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Store Items',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _storeItems.length,
                  itemBuilder: (context, index) {
                    final item = _storeItems[index];
                    final TextEditingController priceEditController =
                        TextEditingController(text: item.price.toString());
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            // Small image preview
                            Image.network(item.avatarurl, width: 80, height: 80, fit: BoxFit.cover),
                            const SizedBox(width: 20),
                            // Price edit field
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: priceEditController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Price',
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Update button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: () async {
                                final newPrice = int.tryParse(priceEditController.text);
                                if (newPrice != null) {
                                  final docId = (await FirebaseFirestore.instance
                                          .collection('store_default')
                                          .where('avatarurl', isEqualTo: item.avatarurl)
                                          .get())
                                      .docs
                                      .first
                                      .id;
                                  await _updatePrice(docId, newPrice);
                                }
                              },
                              child: const Text('Update',style: TextStyle(color: Colors.white),),
                            ),
                            const SizedBox(width: 10),
                            // Delete button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: () async {
                                final docId = (await FirebaseFirestore.instance
                                        .collection('store_default')
                                        .where('avatarurl', isEqualTo: item.avatarurl)
                                        .get())
                                    .docs
                                    .first
                                    .id;
                                await _deleteItem(docId, item.avatarurl);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.white),),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}