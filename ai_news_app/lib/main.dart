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
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914), // Apple News vibrant red/accent style
          surface: Color(0xFF1E1E24),
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
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
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
            const Icon(Icons.newspaper, size: 80, color: Color(0xFFE50914)),
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
              'One Subscription to Hundreds of Publications',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
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
  String _selectedCategoryTab = 'Featured';

  // Magazine / Publication Covers
  final List<Map<String, String>> _magazineCovers = [
    {
      "title": "Global Economy Special",
      "publisher": "The Economist",
      "imageUrl": "https://picsum.photos/seed/mag-economist/300/400",
    },
    {
      "title": "AI & The New Workforce",
      "publisher": "TIME 100",
      "imageUrl": "https://picsum.photos/seed/mag-time/300/400",
    },
    {
      "title": "Geopolitical Shifts 2026",
      "publisher": "The New Yorker",
      "imageUrl": "https://picsum.photos/seed/mag-newyorker/300/400",
    },
    {
      "title": "Tech & Venture Capital",
      "publisher": "Wired Global",
      "imageUrl": "https://picsum.photos/seed/mag-wired/300/400",
    },
  ];

  // Featured Stories
  final List<Map<String, String>> _topStories = [
    {
      "category": "Economy",
      "publisher": "Bloomberg",
      "title": "Global Markets Adjust as Rate Shifts Stabilize Tech Ventures",
      "summary": "Key insights on venture capital trends and inflation indexes...",
      "imageUrl": "https://picsum.photos/seed/story-economy/600/400",
    },
    {
      "category": "Geopolitics",
      "publisher": "Reuters",
      "title": "US-Iran Relations & Critical Maritime Shipping Straits",
      "summary": "Analyzing trade routes, security frameworks, and global oil impact...",
      "imageUrl": "https://picsum.photos/seed/story-geopolitics/600/400",
    },
    {
      "category": "Technology",
      "publisher": "TechCrunch",
      "title": "Bangladesh Tech Ecosystem Expands with Cross-Border AI Startups",
      "summary": "Local engineers lead innovative agentic models for regional scale...",
      "imageUrl": "https://picsum.photos/seed/story-tech/600/400",
    },
  ];

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
          _searchResults = data;
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Text(
              'Honeycomb',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
            ),
            SizedBox(width: 4),
            Text(
              'Discover',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () => _showBKashModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;
          return Row(
            children: [
              Expanded(
                flex: isDesktop ? 3 : 5,
                child: _buildAppleNewsFeed(),
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

  Widget _buildAppleNewsFeed() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Featured', 'Magazines', 'Newspapers', 'Catalog', 'Sports', 'Puzzles'].map((tab) {
              bool isSelected = _selectedCategoryTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(tab),
                  selected: isSelected,
                  selectedColor: Colors.white,
                  backgroundColor: const Color(0xFF1E1E24),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryTab = tab;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Top Publications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _magazineCovers.length,
            itemBuilder: (context, index) {
              final mag = _magazineCovers[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          mag['imageUrl']!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mag['publisher']!,
                      style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      mag['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Selected by Honeycomb Editors',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        ..._topStories.map((story) => _buildHeroNewsCard(story)),
      ],
    );
  }

  Widget _buildHeroNewsCard(Map<String, String> story) {
    return GestureDetector(
      onTap: () => _executeSearch(story['title']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    story['imageUrl']!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        story['publisher']!.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story['summary']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, size: 14, color: Color(0xFFE50914)),
                      SizedBox(width: 6),
                      Text(
                        'Interrogate with Honeycomb AI',
                        style: TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISearchPanel() {
    return Container(
      color: const Color(0xFF16161A),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conversational AI Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              hintText: 'Ask about any news event...',
              filled: true,
              fillColor: const Color(0xFF222228),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Color(0xFFE50914)),
                onPressed: () => _executeSearch(_queryController.text),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onSubmitted: _executeSearch,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                : _searchResults == null
                    ? const Center(
                        child: Text(
                          'Tap any story card or type a query to interrogate context',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Synthesized Answer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                            const SizedBox(height: 8),
                            Text(_searchResults!['answer'] ?? '', style: const TextStyle(fontSize: 15, height: 1.5)),
                            const SizedBox(height: 20),
                            if (_searchResults!['sources'] != null) ...[
                              const Text('Sources & Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                              const SizedBox(height: 8),
                              ...(_searchResults!['sources'] as List).map((src) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.link, size: 18, color: Colors.grey),
                                    title: Text(src['title'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.blueAccent)),
                                  )),
                              const SizedBox(height: 20),
                            ],
                            if (_searchResults!['suggestions'] != null) ...[
                              const Text('Follow-up Prompts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (_searchResults!['suggestions'] as List)
                                    .map((chip) => ActionChip(
                                          label: Text(chip.toString(), style: const TextStyle(fontSize: 12)),
                                          backgroundColor: const Color(0xFF222228),
                                          side: const BorderSide(color: Color(0xFFE50914)),
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
      backgroundColor: const Color(0xFF1E1E24),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 48, color: Color(0xFFE50914)),
            const SizedBox(height: 12),
            const Text('Upgrade to Honeycomb Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Unlock all subscriber editions, unlimited AI deep context, and exclusive feeds for ৳199/month.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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