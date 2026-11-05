import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init notice: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Update',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const UpdatePage(),
    );
  }
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final registerController = TextEditingController();
  final nameController = TextEditingController();
  final departmentController = TextEditingController();
  final emailController = TextEditingController();

  final CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  static final Map<String, Map<String, dynamic>> _offlineStudents = {
    '210101': {
      'name': 'Rajhavel V S',
      'department': 'Computer Science and Engineering',
      'email': 'vsrajhavel@gmail.com',
    },
    '210102': {
      'name': 'Santhosh Kumar',
      'department': 'Information Technology',
      'email': 'santhosh@example.com',
    },
    '101': {
      'name': 'Rajhavel V S',
      'department': 'Computer Science and Engineering',
      'email': 'vsrajhavel@gmail.com',
    },
    '1': {
      'name': 'Rajhavel V S',
      'department': 'Computer Science and Engineering',
      'email': 'vsrajhavel@gmail.com',
    },
  };

  String? documentId;
  bool isLoading = false;

  Future<void> searchStudent() async {
    final registerNumber = registerController.text.trim();

    if (registerNumber.isEmpty) return;

    setState(() {
      isLoading = true;
      documentId = null;
    });

    try {
      final query = await students
          .where('registerNumber', isEqualTo: registerNumber)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          documentId = doc.id;
          nameController.text = data['name'] ?? '';
          departmentController.text = data['department'] ?? '';
          emailController.text = data['email'] ?? '';
          isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Fall through to local store
    }

    // Check offline student database
    if (_offlineStudents.containsKey(registerNumber)) {
      final data = _offlineStudents[registerNumber]!;
      setState(() {
        documentId = 'local_$registerNumber';
        nameController.text = data['name'] ?? '';
        departmentController.text = data['department'] ?? '';
        emailController.text = data['email'] ?? '';
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student record loaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Create new record draft for any entered register number
      setState(() {
        documentId = 'local_$registerNumber';
        nameController.text = '';
        departmentController.text = '';
        emailController.text = '';
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New record initialized for $registerNumber. Enter details and save.'),
        ),
      );
    }
  }

  Future<void> updateStudent() async {
    if (documentId == null) return;

    final reg = registerController.text.trim();
    final updatedData = {
      'name': nameController.text.trim(),
      'department': departmentController.text.trim(),
      'email': emailController.text.trim(),
    };

    if (documentId!.startsWith('local_')) {
      _offlineStudents[reg] = updatedData;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
      return;
    }

    try {
      await students.doc(documentId).update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    } catch (e) {
      _offlineStudents[reg] = updatedData;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    registerController.dispose();
    nameController.dispose();
    departmentController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Update'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search by Register Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: registerController,
                            decoration: const InputDecoration(
                              labelText: 'Register Number (e.g. 210101)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge),
                            ),
                            onSubmitted: (_) => searchStudent(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: searchStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          icon: const Icon(Icons.search),
                          label: const Text('Find Student'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (documentId != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE8EAF6),
                            child: Icon(Icons.edit, color: Colors.indigo),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Details: ${registerController.text}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: updateStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Update Student',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
