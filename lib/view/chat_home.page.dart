import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfliq_app/model/chat_user_model.dart';
import 'package:myfliq_app/services/chat_services.dart';
import 'package:myfliq_app/view/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  late Future<List<ChatUser>> _chatUsersFuture;
  List<ChatUser> _allUsers = [];
  List<ChatUser> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatUsersFuture = fetchChatUsers().then((users) {
      _allUsers = users;
      _filteredUsers = users;
      return users;
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Messages",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Horizontal users list
              FutureBuilder<List<ChatUser>>(
                future: _chatUsersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No users found."));
                  }

                  final users = _allUsers;
                  return SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 40),
                      itemBuilder: (_, index) {
                        final user = users[index];
                        return GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final senderId = prefs.getString(
                              'user_id',
                            ); // 👈 store logged-in ID here

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  senderId: int.parse(senderId!),
                                  receiverId: int.parse(user.id), // ChatUser.id
                                  receiverName: user.name,
                                  receiverImage: user.imageUrl,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: user.imageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(user.imageUrl)
                                    : null,
                                backgroundColor: Colors.grey[300],
                                child: user.imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 28)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  suffixIcon: Image.asset('assets/images/search-favorite.png'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ), // 👈 focus border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ), // 👈 default border
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chat",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Chat List
              Expanded(
                child: FutureBuilder<List<ChatUser>>(
                  future: _chatUsersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CupertinoActivityIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (_filteredUsers.isEmpty) {
                      return const Center(child: Text("No chats found."));
                    }

                    return ListView.separated(
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (_, i) {
                        final user = _filteredUsers[i];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: user.imageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(user.imageUrl)
                                : null,
                            child: user.imageUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          trailing: const Text(
                            "10:00 AM",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),

                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final senderId = prefs.getString(
                              'user_id',
                            ); // 👈 store logged-in ID here

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  senderId: int.parse(senderId!),
                                  receiverId: int.parse(user.id), // ChatUser.id
                                  receiverName: user.name,
                                  receiverImage: user.imageUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
