import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA3KTz-6FNZtCmk612shIZJAXkUJ4pyivw",
        authDomain: "honeycomb-ai-d8551.firebaseapp.com",
        projectId: "honeycomb-ai-d8551",
        storageBucket: "honeycomb-ai-d8551.firebasestorage.app",
        messagingSenderId: "815499266214",
        appId: "1:815499266214:web:fb8877e91b63a8e2e04c67",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

  runApp(const HoneycombApp());
}

class HoneycombApp extends StatelessWidget {
  const HoneycombApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honeycomb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB703),
          surface: Color(0xFF18181C),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFB703)),
            ),
          );
        }
        if (snapshot.hasData) {
          return HoneycombDashboard(user: snapshot.data!);
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } catch (e) {
      debugPrint("Login Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hive, size: 80, color: Color(0xFFFFB703)),
            const SizedBox(height: 16),
            const Text(
              'Honeycomb',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-Driven Personal News Engine',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: const Icon(Icons.login, color: Colors.black),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB703),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DemoDashboard(),
                  ),
                );
              },
              child: const Text(
                'Skip Login for Local Testing',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoDashboard extends StatelessWidget {
  const DemoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const HoneycombDashboardUI();
  }
}

class HoneycombDashboard extends StatelessWidget {
  final User user;
  const HoneycombDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return HoneycombDashboardUI(userId: user.uid);
  }
}

class HoneycombDashboardUI extends StatefulWidget {
  final String userId;
  const HoneycombDashboardUI({super.key, this.userId = "demo_user"});

  @override
  State<HoneycombDashboardUI> createState() => _HoneycombDashboardUIState();
}

class _HoneycombDashboardUIState extends State<HoneycombDashboardUI> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _searchResults;

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;

    _queryController.text = query;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://honeycomb-app.onrender.com/api/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'user_id': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = data; // Fixed variable name
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar("Failed to fetch search results from server.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Connection error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.hive, color: Color(0xFFFFB703)),
            SizedBox(width: 8),
            Text('Honeycomb', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showBKashModal(context),
            icon: const Icon(Icons.bolt, size: 16, color: Colors.black),
            label: const Text('Upgrade Pro', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB703)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return Row(
            children: [
              Expanded(
                flex: isDesktop ? 3 : 5,
                child: _buildPersonalFeed(),
              ),
              if (isDesktop) const VerticalDivider(width: 1, color: Colors.white12),
              if (isDesktop)
                Expanded(
                  flex: 2,
                  child: _buildAISearchPanel(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalFeed() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Your Curated Feed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Personalized by Honeycomb AI', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        _buildNewsCard('Global Economy & Inflation Analysis', 'Markets adjust as rate adjustments stabilize global tech ventures...', 'Economy'),
        _buildNewsCard('US-Iran Relations & Maritime Shipping', 'Key security developments in critical trade straits impact oil prices...', 'Geopolitics'),
        _buildNewsCard('Bangladesh Tech Ecosystem Expansion', 'Local startups leverage AI-first products for global cross-border scale...', 'Tech'),
      ],
    );
  }

  Widget _buildNewsCard(String title, String summary, String category) {
    return Card(
      color: const Color(0xFF18181C),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(category, style: const TextStyle(fontSize: 10, color: Colors.black)),
              backgroundColor: const Color(0xFFFFB703),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(summary, style: const TextStyle(color: Colors.grey, height: 1.4)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _executeSearch(title),
              icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFFB703)),
              label: const Text('Ask Honeycomb AI', style: TextStyle(color: Color(0xFFFFB703))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAISearchPanel() {
    return Container(
      color: const Color(0xFF121215),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conversational AI Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              hintText: 'Ask anything (e.g., Oil prices impact)...',
              filled: true,
              fillColor: const Color(0xFF18181C),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFFFB703)),
                onPressed: () => _executeSearch(_queryController.text),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onSubmitted: _executeSearch,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB703)))
                : _searchResults == null
                    ? const Center(child: Text('Ask a question to trigger AI synthesis', style: TextStyle(color: Colors.grey)))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Synthesized Answer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFB703))),
                            const SizedBox(height: 8),
                            Text(_searchResults!['answer'] ?? '', style: const TextStyle(fontSize: 15, height: 1.5)),
                            const SizedBox(height: 20),
                            if (_searchResults!['sources'] != null) ...[
                              const Text('Sources & Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFB703))),
                              const SizedBox(height: 8),
                              ...(_searchResults!['sources'] as List).map((src) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.link, size: 18, color: Colors.grey),
                                    title: Text(src['title'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.blueAccent)),
                                  )),
                              const SizedBox(height: 20),
                            ],
                            if (_searchResults!['suggestions'] != null) ...[
                              const Text('Suggested Cells', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFB703))),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (_searchResults!['suggestions'] as List)
                                    .map((chip) => ActionChip(
                                          label: Text(chip.toString(), style: const TextStyle(fontSize: 12)),
                                          backgroundColor: const Color(0xFF18181C),
                                          side: const BorderSide(color: Color(0xFFFFB703)),
                                          onPressed: () => _executeSearch(chip.toString()),
                                        ))
                                    .toList(),
                              ),
                            ]
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showBKashModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, size: 48, color: Color(0xFFFFB703)),
            const SizedBox(height: 12),
            const Text('Upgrade to Honeycomb Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Get unlimited Claude AI searches and personalized deep feeds for ৳199/month.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showErrorSnackBar("bKash Sandbox Payment Gateway Initiated!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2136E),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Pay ৳199 with bKash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}