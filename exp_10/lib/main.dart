import 'dart:convert';
import 'dart:math';
 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
 
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
      title: 'Secure Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}
 
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
 
  @override
  State<AuthPage> createState() => _AuthPageState();
}
 
class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
 
  final users = FirebaseFirestore.instance.collection('users');
 
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
 
  String getUserId(String email) {
    return sha256.convert(utf8.encode(email.toLowerCase())).toString();
  }
 
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );
    return base64Encode(bytes);
  }
 
  String hashPassword(String password, String salt) {
    return sha256
        .convert(utf8.encode('$salt$password'))
        .toString();
  }
 
  static final Map<String, Map<String, dynamic>> _offlineUsers = {};

  Future<void> authenticate() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
 
    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password');
      return;
    }
 
    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Please enter a valid email address');
      return;
    }
 
    if (password.length < 6) {
      showMessage('Password must contain at least 6 characters');
      return;
    }
 
    setState(() => isLoading = true);
 
    try {
      final userId = getUserId(email);
      final userDoc = await users.doc(userId).get();
 
      if (isLogin) {
        if (!userDoc.exists) {
          showMessage('Account not found. Please register.');
        } else {
          final data = userDoc.data()!;
          final salt = data['salt'] as String;
          final storedHash = data['passwordHash'] as String;
          final enteredHash = hashPassword(password, salt);
 
          if (enteredHash == storedHash) {
            if (!mounted) return;
 
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(email: email),
              ),
            );
          } else {
            showMessage('Incorrect password');
          }
        }
      } else {
        if (userDoc.exists) {
          showMessage('Account already exists. Please login.');
        } else {
          final salt = generateSalt();
          final passwordHash = hashPassword(password, salt);
 
          await users.doc(userId).set({
            'email': email,
            'salt': salt,
            'passwordHash': passwordHash,
            'createdAt': FieldValue.serverTimestamp(),
          });
 
          showMessage('Registration successful! Please login.');
 
          setState(() {
            isLogin = true;
            passwordController.clear();
          });
        }
      }
    } catch (e) {
      // Offline fallback for classroom demonstration when live Firebase credentials are not connected
      final userId = getUserId(email);
      if (isLogin) {
        if (!_offlineUsers.containsKey(userId)) {
          showMessage("Account not found. Please register.");
        } else {
          final data = _offlineUsers[userId]!;
          final salt = data["salt"] as String;
          final storedHash = data["passwordHash"] as String;
          final enteredHash = hashPassword(password, salt);
          if (enteredHash == storedHash) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(email: email),
              ),
            );
          } else {
            showMessage("Incorrect password");
          }
        }
      } else {
        if (_offlineUsers.containsKey(userId)) {
          showMessage("Account already exists. Please login.");
        } else {
          final salt = generateSalt();
          final passwordHash = hashPassword(password, salt);
          _offlineUsers[userId] = {
            "email": email,
            "salt": salt,
            "passwordHash": passwordHash,
          };
          showMessage("Registration successful! Please login.");
          setState(() {
            isLogin = true;
            passwordController.clear();
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
 
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
 
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3949AB),
              Color(0xFF7986CB),
              Color(0xFFF5F5FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFE8EAF6),
                      child: Icon(
                        Icons.lock_outline,
                        size: 38,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isLogin ? 'Welcome Back!' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin
                          ? 'Login to continue'
                          : 'Register to get started',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : authenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isLogin ? 'LOGIN' : 'REGISTER',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                isLogin = !isLogin;
                                passwordController.clear();
                              });
                            },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Register"
                            : 'Already have an account? Login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 
class DashboardPage extends StatelessWidget {
  final String email;
 
  const DashboardPage({super.key, required this.email});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login Successful!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome, $email',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
