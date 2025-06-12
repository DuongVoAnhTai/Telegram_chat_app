import 'dart:io';
import 'dart:convert';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/core/navigation/routers.dart';
import 'package:frontend/core/services/token.dart';
import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:frontend/features/group/presentation/pages/add_member_page.dart';
import 'package:frontend/features/recentCallScreen/data/repositories/recentCall_repository_impl.dart';
import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_bloc.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_event.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/features/chat/domain/entities/message_entity.dart';

import 'package:frontend/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/chat/presentation/pages/call_screen.dart';
import 'package:stream_video/stream_video.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  final String? profilePic;
  const ChatPage({
    required this.conversationId,
    required this.mate,
    this.profilePic,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with RouteAware {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _storage = FlutterSecureStorage();
  String userId = '';
  List<File> _selectedImages = []; // Store multiple picked images for preview
  bool _isUploading = false; // Track upload state
  bool _isSearching = false;
  List<dynamic> _filteredMessages = [];
  bool _isGroup = false;
  List<Participant> _participants = [];
  late String conversationName;
  String? _currentProfilePic; // Add this line to track current profile pic

  @override
  void initState() {
    super.initState();
    _currentProfilePic =
        widget.profilePic; // Initialize with widget's profile pic
    BlocProvider.of<ChatBloc>(
      context,
    ).add(LoadMessageEvent(widget.conversationId));
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(GetParticipants(widget.conversationId));
    fetchUserUI();
    _searchController.addListener(_filterMessages);
    conversationName = widget.mate;
  }

  void updateConversationName(String newName) {
    setState(() {
      conversationName = newName;
    });
  }

  fetchUserUI() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    print("Fetch lai ");
    // Gọi lại khi từ trang khác pop về đây
    BlocProvider.of<ChatBloc>(
      context,
    ).add(LoadMessageEvent(widget.conversationId));
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(GetParticipants(widget.conversationId));
    fetchUserUI();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _initCallClient() async {
  //   final userToken = await _storage.read(key: 'token');
  //   final userId = await _storage.read(key: 'userId');

  //   if (userToken == null || userId == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Missing user information')));
  //     return;
  //   }

  //   // Get Stream Video token from backend
  //   final response = await http.post(
  //     Uri.parse('http://10.0.2.2:3000/auth/stream-token'),
  //     headers: {
  //       'Authorization': 'Bearer $userToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to get Stream Video token');
  //   }

  //   final streamToken = jsonDecode(response.body)['token'];

  //   // Initialize Stream Video client
  //   StreamVideo.reset();
  //   client = StreamVideo(
  //     'k5dmbjjwggje',
  //     user: User.regular(userId: userId, role: 'user', name: 'User $userId'),
  //     userToken: streamToken,
  //   );
  // }

  void _filterMessages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    List<String> imageUrls = [];

    // If images are selected, upload them
    if (_selectedImages.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });
      try {
        // Upload each image and collect the URLs
        for (var image in _selectedImages) {
          final uploadedUrl = await CloudinaryHelper.uploadImage(image);
          imageUrls.add(uploadedUrl);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload images: $e')));
        setState(() {
          _isUploading = false;
        });
        return;
      } finally {
        setState(() {
          _isUploading = false;
          _selectedImages = []; // Clear the preview after sending
        });
      }
    }

    // Send the message with text and/or images
    if (content.isNotEmpty || imageUrls.isNotEmpty) {
      BlocProvider.of<ChatBloc>(context).add(
        SendMessagesEvent(widget.conversationId, content, imageUrls: imageUrls),
      );
      // Scroll to bottom after sending message
      _scrollToBottom();
    }
    _messageController.clear();
  }

  void _sendVideoCallMessage(String status) {
    BlocProvider.of<ChatBloc>(context).add(
      SendMessagesEvent(
        widget.conversationId,
        "Video call $status",
        imageUrls: [],
      ),
    );
  }

  void _startVideoCall() async {
    try {
      _sendVideoCallMessage("started");

      // Gửi recent call về server
      final recentCallRepo = context.read<RecentcallRepositoryImpl>();
      await recentCallRepo.createRecentCall(widget.conversationId, 'video');

      final client = StreamVideo.instance;
      // Connect the client
      await client.connect();

      // Create the call
      var call = client.makeCall(
        callType: StreamCallType(),
        id: widget.conversationId,
      );

      // Get or create the call
      await call.getOrCreate();

      if (!mounted) return;

      // Navigate to call screen
      Navigator.push(
        context,

        MaterialPageRoute(
          builder:
              (context) => CallScreen(
                call: call,
                onCallEnded: () {
                  _sendVideoCallMessage("ended");
                  recentCallRepo.endRecentCall(widget.conversationId);
                },
              ),
        ),
      );
    } catch (e) {
      debugPrint('Error joining or creating call: $e');
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start video call: $e')));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(
          File(pickedFile.path),
        ); // Add the new image to the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ParticipantsLoaded) {
          setState(() {
            _isGroup = state.participants.length > 2;
            print(
              'Participants loaded: ${state.participants.length}, canAddMember: $_isGroup',
            );

            _participants = state.participants;
          });
        } else if (state is ConversationError) {
          setState(() {
            _isGroup = false;
            _participants = [];
          });
        } else if (state is UpdatedGroupProfilePic) {
          // Update profile picture when it's changed
          if (state.conversationId == widget.conversationId) {
            setState(() {
              _currentProfilePic = state.profilePic;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                backgroundImage:
                    _currentProfilePic != null && _currentProfilePic!.isNotEmpty
                        ? NetworkImage(_currentProfilePic!)
                        : null,
                child:
                    _currentProfilePic == null || _currentProfilePic!.isEmpty
                        ? Text(
                          _isGroup
                              ? _getGroupAvatarText(conversationName)
                              : conversationName.isNotEmpty
                              ? conversationName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: AppColors.white),
                        )
                        : null,
              ),
              SizedBox(width: 10),
              Text(
                conversationName.length > 8
                    ? '${conversationName.substring(0, 8)}...'
                    : conversationName,
                style: TextStyle(fontSize: 26),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _startVideoCall,
              icon: Icon(Icons.videocam, color: Colors.grey),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.grey,
              ),
            ),
            Builder(
              builder:
                  (context) => PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    position: PopupMenuPosition.under,
                    onSelected: (value) async {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Conversation'),
                              content: const Text(
                                'Are you sure you want to delete this conversation? This action cannot be undone.',
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<ConversationBloc>(
                                      context,
                                    ).add(
                                      DeleteConversation(widget.conversationId),
                                    );
                                    Navigator.of(context).pop(); // Close dialog
                                    Navigator.of(context).pop(); // Go back
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == 'group_settings' && _isGroup) {
                        final result = await context.push(
                          "/group-setting?conversationId=${widget.conversationId}&participants=$_participants",
                        );
                        if (result != null && result != "") {
                          updateConversationName(result.toString());
                        }
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Conversation',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isGroup)
                            const PopupMenuItem<String>(
                              value: 'group_settings',
                              child: Row(
                                children: [
                                  Icon(Icons.group, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Group Settings',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                  ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            if (_isSearching)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search in messages...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  autofocus: true,
                ),
              ),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoadedState) {
                    // Filter messages if searching
                    _filteredMessages =
                        _isSearching
                            ? state.messages
                                .where(
                                  (message) =>
                                      message.text.toLowerCase().contains(
                                        _searchController.text.toLowerCase(),
                                      ),
                                )
                                .toList()
                            : state.messages;

                    if (_filteredMessages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearching
                                  ? Icons.search_off
                                  : Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? "No messages found"
                                  : "No messages yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Schedule scroll to bottom after the list is built
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(20),
                      itemCount: _filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = _filteredMessages[index];
                        final isSentMessage = message.senderId == userId;
                        if (isSentMessage) {
                          return _buildSentMessage(
                            context,
                            message.text,
                            message.image,
                            message.id,
                          );
                        } else {
                          return _buildReceivedMessage(
                            context,
                            message.text,
                            message.image,
                            message,
                          );
                        }
                      },
                    );
                  } else if (state is ChatErrorState) {
                    return Center(child: Text(state.error));
                  }
                  return Center(child: Text("No messages found"));
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(
    BuildContext context,
    String mess,
    List<String>? images,
    MessageEntity message,
  ) {
    // Find the sender's info from participants
    final sender = _participants.firstWhere(
      (p) => p.id == message.senderId,
      orElse: () => Participant(id: '', fullName: 'Unknown', profilePic: ''),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryColor,
            backgroundImage:
                sender.profilePic.isNotEmpty
                    ? NetworkImage(sender.profilePic)
                    : null,
            child:
                sender.profilePic.isEmpty
                    ? Text(
                      sender.fullName.isNotEmpty
                          ? sender.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    )
                    : null,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show sender's name in group chats
                if (_isGroup)
                  Text(
                    sender.fullName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(top: _isGroup ? 6 : 0),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: DefaultColors.receiverMessage,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mess.isNotEmpty)
                        Text(
                          mess,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (images != null && images.isNotEmpty) ...[
                        SizedBox(height: 8),
                        for (var image in images)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.error),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(
    BuildContext context,
    String mess,
    List<String>? images,
    String messageId,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Delete Message'),
                content: Text('Are you sure you want to delete this message?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      BlocProvider.of<ChatBloc>(context).add(
                        DeleteMessageEvent(messageId, widget.conversationId),
                      );
                    },
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 38, top: 5, bottom: 5),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: DefaultColors.receiverMessage,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (mess.isNotEmpty)
                Text(mess, style: Theme.of(context).textTheme.bodyMedium),
              if (images != null && images.isNotEmpty) ...[
                SizedBox(height: 8),
                for (var image in images)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        image,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(Icons.error),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25),
      ),
      margin: EdgeInsets.all(25),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the left
        children: [
          // Image previews if images are selected
          if (_selectedImages.isNotEmpty)
            Wrap(
              spacing: 8, // Space between images
              children:
                  _selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(
                                index,
                              ); // Remove the specific image
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey),
                    if (_isUploading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                child: Icon(Icons.send, color: Colors.grey),
                onTap: _isUploading ? null : _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGroupAvatarText(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
