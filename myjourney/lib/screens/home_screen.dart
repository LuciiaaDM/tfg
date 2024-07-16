import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';
import '../widgets/bottom_navigation.dart';
import 'create_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';
import 'filters_screen.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomeScreenContent(),
    CreateScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'type': 'Cualquiera',
    'category': 'Cualquiera',
    'minPrice': null,
    'maxPrice': null,
  };

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _updateFilters(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FiltersScreen()),
              );
              if (result != null) {
                _updateFilters(result);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por ubicación...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(8.0),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var posts = snapshot.data!.docs.map((doc) {
            return Post.fromJson(doc.data() as Map<String, dynamic>);
          }).where((post) {
            return post.location.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          // filtros adicionales
          if (_filters['type'] != 'Cualquiera') {
            posts = posts.where((post) => post.type.toLowerCase() == _filters['type'].toLowerCase()).toList();
          }
          if (_filters['category'] != 'Cualquiera') {
            posts = posts.where((post) => post.category.toLowerCase() == _filters['category'].toLowerCase()).toList();
          }
          if (_filters['minPrice'] != null) {
            posts = posts.where((post) => post.price != null && post.price! >= _filters['minPrice']).toList();
          }
          if (_filters['maxPrice'] != null) {
            posts = posts.where((post) => post.price != null && post.price! <= _filters['maxPrice']).toList();
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}
