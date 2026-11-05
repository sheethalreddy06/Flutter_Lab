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
      title: 'StudentHub Cloud',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final nameController = TextEditingController(text: 'Rajhavel V S');
  final registerController = TextEditingController(text: 'URK23CS7040');
  final departmentController = TextEditingController(text: 'Computer Science and Engineering');
  final emailController = TextEditingController(text: 'vsrajhavel@gmail.com');

  final CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  final List<Map<String, dynamic>> _localStudents = [
    {
      'name': 'Rajhavel V S',
      'registerNumber': 'URK23CS7040',
      'department': 'Computer Science and Engineering',
      'email': 'vsrajhavel@gmail.com',
    },
  ];

  Future<void> addStudent() async {
    if (nameController.text.isEmpty ||
        registerController.text.isEmpty ||
        departmentController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final newStudent = {
      'name': nameController.text.trim(),
      'registerNumber': registerController.text.trim(),
      'department': departmentController.text.trim(),
      'email': emailController.text.trim(),
      'createdAt': DateTime.now(),
    };

    try {
      await students.add({
        ...newStudent,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Graceful local fallback
    }

    setState(() {
      _localStudents.insert(0, newStudent);
    });

    nameController.clear();
    registerController.clear();
    departmentController.clear();
    emailController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    registerController.dispose();
    departmentController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudentHub Cloud (Firestore)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: registerController,
              decoration: const InputDecoration(
                labelText: 'Register Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Save Student to Cloud Firestore'),
              ),
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registered Students',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor: const Color(0xFFE8EAF6),
                  label: Text(
                    '${_localStudents.length} Records',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: students
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<Map<String, dynamic>> displayList = [];

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    displayList = snapshot.data!.docs
                        .map((d) => d.data() as Map<String, dynamic>)
                        .toList();
                  } else {
                    displayList = _localStudents;
                  }

                  if (displayList.isEmpty) {
                    return const Center(
                      child: Text('No students registered yet'),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final data = displayList[index];
                      final bool isUser = (data['registerNumber'] ?? '').toString().toUpperCase() == 'URK23CS7040';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isUser
                              ? const BorderSide(color: Colors.indigo, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUser ? Colors.indigo : const Color(0xFFC5CAE9),
                            child: Icon(
                              Icons.person,
                              color: isUser ? Colors.white : Colors.indigo,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(data['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (isUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EAF6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('YOU',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            'Register No: ${data['registerNumber']}\n'
                            'Department: ${data['department']}\n'
                            'Email: ${data['email']}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
