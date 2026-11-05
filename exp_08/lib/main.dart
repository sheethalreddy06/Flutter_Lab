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
      title: 'Student Search',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController =
      TextEditingController(text: 'Rajhavel');

  static final List<Map<String, dynamic>> _allStudents = [
    {
      'name': 'Rajhavel V S',
      'registerNumber': 'URK23CS7040',
      'department': 'Computer Science and Engineering',
      'email': 'vsrajhavel@gmail.com',
    },
    {
      'name': 'Santhosh Kumar',
      'registerNumber': 'URK23CS7041',
      'department': 'Information Technology',
      'email': 'santhosh@example.com',
    },
    {
      'name': 'Praveen R',
      'registerNumber': 'URK23CS7042',
      'department': 'Computer Science and Engineering',
      'email': 'praveen@example.com',
    },
  ];

  List<Map<String, dynamic>> displayResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    searchStudents('Rajhavel');
  }

  Future<void> searchStudents(String value) async {
    final queryText = value.trim();
    if (queryText.isEmpty) {
      setState(() {
        displayResults = [];
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('students')
          .where('name', isGreaterThanOrEqualTo: queryText)
          .where('name', isLessThanOrEqualTo: '$queryText\uf8ff')
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          displayResults = query.docs
              .map((d) => d.data())
              .toList();
          isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Fall through to local collection
    }

    // Filter local collection by Name or Register Number
    final qLower = queryText.toLowerCase();
    final matched = _allStudents.where((s) {
      final n = (s['name'] ?? '').toString().toLowerCase();
      final r = (s['registerNumber'] ?? '').toString().toLowerCase();
      return n.contains(qLower) || r.contains(qLower);
    }).toList();

    setState(() {
      displayResults = matched;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text('Student Search (Firestore)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search student by Name or Reg No',
                        hintText: 'e.g. Rajhavel, URK23CS7040, Santhosh',
                        prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchStudents('');
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: searchStudents,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => searchStudents(searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Search Firestore', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasSearched)
                  Chip(
                    backgroundColor: const Color(0xFFE8EAF6),
                    label: Text(
                      '${displayResults.length} Found',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : !hasSearched
                      ? const Center(
                          child: Text(
                            'Enter a student name or register number to search',
                          ),
                        )
                      : displayResults.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching students found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayResults.length,
                              itemBuilder: (context, index) {
                                final data = displayResults[index];
                                final bool isUser = (data['registerNumber'] ?? '')
                                        .toString()
                                        .toUpperCase() ==
                                    'URK23CS7040';

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isUser
                                        ? const BorderSide(color: Colors.indigo, width: 2)
                                        : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(14),
                                    leading: CircleAvatar(
                                      backgroundColor: isUser
                                          ? Colors.indigo
                                          : const Color(0xFFC5CAE9),
                                      child: Icon(
                                        Icons.person,
                                        color: isUser ? Colors.white : Colors.indigo,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          data['name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (isUser) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8EAF6),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('YOU',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Register No: ${data['registerNumber']}\n'
                                        'Department: ${data['department']}\n'
                                        'Email: ${data['email']}',
                                      ),
                                    ),
                                    isThreeLine: true,
                                  ),
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
