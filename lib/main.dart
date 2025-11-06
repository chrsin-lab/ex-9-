import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(
      title: "Employee Application",
      home: EmployeeScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => EmployeeScreenState();
}

class EmployeeScreenState extends State<EmployeeScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text controllers
  final _nameController = TextEditingController();
  final _empIdController = TextEditingController();
  final _salaryController = TextEditingController();

  String _status = "";

  // Function to add employee to Firestore
  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('employees').add({
        'name': _nameController.text,
        'empid': _empIdController.text,
        'salary': double.tryParse(_salaryController.text) ?? 0.0,
      });

      // Clear fields
      _nameController.clear();
      _empIdController.clear();
      _salaryController.clear();

      setState(() {
        _status = "Data Saved Successfully!";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee Added Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Application"),
        backgroundColor: Colors.amberAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name TextField
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter your name!" : null,
                ),
                const SizedBox(height: 10),

                // Employee ID TextField
                TextFormField(
                  controller: _empIdController,
                  decoration: const InputDecoration(
                    labelText: "Enter your EmpID",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter your empId!" : null,
                ),
                const SizedBox(height: 10),

                // Salary TextField
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: "Enter your Salary",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter your salary!" : null,
                ),
                const SizedBox(height: 10),

                // Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addEmployee,
                  child: const Text('Save Details'),
                ),
                const SizedBox(height: 20),

                // Status message
                Text(
                  _status,
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 20),

                // 🔹 StreamBuilder for Firestore employees list
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('employees').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No employee records found.');
                    }

                    final employees = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.deepPurple),
                            title: Text(emp['name'] ?? 'No Name'),
                            subtitle: Text(
                              'EmpID: ${emp['empid'] ?? '-'} • Salary: ${emp['salary']?.toString() ?? '-'}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
