import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UpdateProductApp(),
  ));
}

class UpdateProductApp extends StatefulWidget {
  const UpdateProductApp({super.key});

  @override
  State<UpdateProductApp> createState() => _UpdateProductAppState();
}

class _UpdateProductAppState extends State<UpdateProductApp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Map<String, dynamic>? _product;
  String _message = "";
  String? _productId; // To track which document to update

  // 🔍 Search Product Function
  Future<void> _searchProduct() async {
    String productName = _nameController.text.trim();

    if (productName.isEmpty) {
      setState(() {
        _message = "Please enter a product name!";
        _product = null;
      });
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        setState(() {
          _productId = doc.id;
          _product = doc.data() as Map<String, dynamic>;
          _quantityController.text = _product!['quantity'].toString();
          _priceController.text = _product!['price'].toString();
          _message = "";
        });
      } else {
        setState(() {
          _product = null;
          _productId = null;
          _message = "Product not found.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  // ✏️ Update Product Function
  Future<void> _updateProduct() async {
    if (_productId == null) {
      setState(() {
        _message = "Please search for a product first!";
      });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_productId)
          .update({
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
      });

      setState(() {
        _message = "Product details updated successfully!";
      });
    } catch (e) {
      setState(() {
        _message = "Error updating product: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Product Details"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Product Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Enter Product Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // 🔍 Search Button
              ElevatedButton(
                onPressed: _searchProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Search"),
              ),
              const SizedBox(height: 20),

              if (_product != null) ...[
                // 🧾 Quantity Field
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Update Quantity",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // 💰 Price Field
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Update Price",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // ✏️ Update Button
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Update"),
                ),
              ],

              const SizedBox(height: 20),

              // 🟢 Status Message
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains("Error")
                      ? Colors.red
                      : Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
