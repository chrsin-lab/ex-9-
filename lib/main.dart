import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProductSearchApp(),
  ));
}

class ProductSearchApp extends StatefulWidget {
  const ProductSearchApp({super.key});

  @override
  State<ProductSearchApp> createState() => _ProductSearchAppState();
}

class _ProductSearchAppState extends State<ProductSearchApp> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _product;
  String _message = "";

  Future<void> _searchProduct() async {
    String productName = _searchController.text.trim();

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
        setState(() {
          _product = snapshot.docs.first.data() as Map<String, dynamic>;
          _message = "";
        });
      } else {
        setState(() {
          _product = null;
          _message = "Product not found";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Search"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input Field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Enter Product Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Search Button
            ElevatedButton(
              onPressed: _searchProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),

            // Display Result
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            if (_product != null)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    "Name: ${_product!['name']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quantity: ${_product!['quantity']}"),
                      Text("Price: ₹${_product!['price']}"),
                      if (_product!['quantity'] < 5)
                        const Text(
                          "Low Stock!",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
