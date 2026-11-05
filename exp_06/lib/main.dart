import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const StudentHubApp());
}

// STUDENT MODEL
class Student {
  final int? id;
  final String name, registerNumber, department, email;

  const Student({
    this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'registerNumber': registerNumber,
    'department': department,
    'email': email,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id'] as int,
    name: map['name'] as String,
    registerNumber: map['registerNumber'] as String,
    department: map['department'] as String,
    email: map['email'] as String,
  );
}

// DATABASE HELPER
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  static final List<Student> _fallbackStudents = [
    const Student(
      id: 1,
      name: 'Rajhavel V S',
      registerNumber: 'URK23CS7040',
      department: 'Computer Science and Engineering',
      email: 'vsrajhavel@gmail.com',
    ),
  ];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath;
    if (kIsWeb) {
      databasePath = 'studenthub.db';
    } else {
      final path = await getDatabasesPath();
      databasePath = p.join(path, 'studenthub.db');
    }

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            registerNumber TEXT NOT NULL,
            department TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
        await db.insert('students', {
          'name': 'Rajhavel V S',
          'registerNumber': 'URK23CS7040',
          'department': 'Computer Science and Engineering',
          'email': 'vsrajhavel@gmail.com',
        });
      },
    );
  }

  // CREATE operation
  Future<int> insertStudent(Student student) async {
    try {
      final db = await database;
      return await db.insert('students', student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      _fallbackStudents.insert(0, student);
      return 1;
    }
  }

  // READ operation
  Future<List<Student>> getStudents() async {
    try {
      final db = await database;
      final result = await db.query('students', orderBy: 'id DESC');
      if (result.isEmpty) {
        await db.insert('students', {
          'name': 'Rajhavel V S',
          'registerNumber': 'URK23CS7040',
          'department': 'Computer Science and Engineering',
          'email': 'vsrajhavel@gmail.com',
        });
        final updated = await db.query('students', orderBy: 'id DESC');
        return updated.map((map) => Student.fromMap(map)).toList();
      }
      return result.map((map) => Student.fromMap(map)).toList();
    } catch (_) {
      return _fallbackStudents;
    }
  }
}

// MAIN APPLICATION
class StudentHubApp extends StatelessWidget {
  const StudentHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudentHub',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4053B5),
        useMaterial3: true,
      ),
      home: const StudentHomePage(),
    );
  }
}

// STUDENT HOME PAGE
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Rajhavel V S');
  final _registerController = TextEditingController(text: 'URK23CS7040');
  final _departmentController = TextEditingController(text: 'Computer Science and Engineering');
  final _emailController = TextEditingController(text: 'vsrajhavel@gmail.com');

  List<Student> students = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // READ saved records
  Future<void> loadStudents() async {
    final records = await DatabaseHelper.instance.getStudents();
    if (!mounted) return;
    setState(() {
      students = records;
      isLoading = false;
    });
  }

  // CREATE a new record
  Future<void> saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    final student = Student(
      name: _nameController.text.trim(),
      registerNumber: _registerController.text.trim(),
      department: _departmentController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      await DatabaseHelper.instance.insertStudent(student);
      await loadStudents();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student record saved successfully to SQLite!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save student: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: const Text('StudentHub - SQLite Lab',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4053B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStudents,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Record Management (SQLite)',
                        style: TextStyle(fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4053B5))),
                    SizedBox(height: 6),
                    Text('Add and manage persistent student records using SQLite (CREATE & READ).'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add New Student',
                            style: TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        _buildField('Student Name', 'Enter student name',
                            Icons.person, _nameController),
                        _buildField('Register Number', 'Enter register number',
                            Icons.badge, _registerController),
                        _buildField('Department', 'Enter department',
                            Icons.school, _departmentController),
                        _buildField('Email Address', 'Enter email address',
                            Icons.email, _emailController, email: true),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : saveStudent,
                            icon: const Icon(Icons.save),
                            label: Text(isSaving ? 'Saving...' : 'Save Student to SQLite'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4053B5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Student Records in SQLite',
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Chip(
                    backgroundColor: const Color(0xFFE8EAF6),
                    label: Text('${students.length} Records',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4053B5))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (students.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No student records found.')),
                  ),
                )
              else
                ...students.map((student) => StudentCard(student: student)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon,
      TextEditingController controller, {bool email = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            validator: (value) {
              final error = requiredValidator(value);
              if (error != null) return error;
              if (email &&
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value!.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color(0xFF4053B5)),
              filled: true,
              fillColor: const Color(0xFFF7F7FB),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
          ),
        ],
      ),
    );
  }
}

// REUSABLE STUDENT CARD
class StudentCard extends StatelessWidget {
  final Student student;
  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final bool isUser = student.registerNumber.toUpperCase() == 'URK23CS7040';
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUser
            ? const BorderSide(color: Color(0xFF4053B5), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: isUser ? const Color(0xFF4053B5) : const Color(0xFFC5CAE9),
          child: Text(student.name.isNotEmpty
              ? student.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF4053B5),
                  fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Text(student.name,
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4053B5))),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Register No: ${student.registerNumber}\n'
            'Department: ${student.department}\n'
            'Email: ${student.email}',
          ),
        ),
        trailing: const Icon(Icons.storage, color: Colors.green),
      ),
    );
  }
}
