import 'dart:io';
import 'dart:convert';
import 'package:frontend/core/helpers/constants.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/chat/presentation/pages/call_screen.dart';
import 'package:stream_video/stream_video.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  final String? profilePic;
  const ChatPage({required this.conversationId, required this.mate, this.profilePic, super.key,});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _storage = FlutterSecureStorage();
  String userId = '';
  List<File> _selectedImages = []; // Store multiple picked images for preview
  bool _isUploading = false; // Track upload state

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(
      context,
    ).add(LoadMessageEvent(widget.conversationId));
    fetchUserUI();
  }

  fetchUserUI() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
    }
    _messageController.clear();
  }

  void _startVoiceCall() async {}

  void _startVideoCall() async {
    try {
      final userToken = await _storage.read(key: 'token');
      final userId = await _storage.read(key: 'userId');

      if (userToken == null || userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Missing user information')));
        return;
      }

      // Get Stream Video token from backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/stream-token'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get Stream Video token');
      }

      final streamToken = jsonDecode(response.body)['token'];

      // Initialize Stream Video client
      final client = StreamVideo(
        'k5dmbjjwggje',
        user: User.regular(userId: userId, role: 'user', name: 'User $userId'),
        userToken: streamToken,
      );

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
        MaterialPageRoute(builder: (context) => CallScreen(call: call)),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              backgroundImage:
                  widget.profilePic != null
                      ? NetworkImage(widget.profilePic!)
                      : null,
              child:
                  widget.profilePic == null
                      ? Text(
                        widget.mate[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.white),
                      )
                      : null,
            ),
            SizedBox(width: 10),
            Text(widget.mate),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call, color: Colors.grey),
          ),
          IconButton(
            onPressed: _startVideoCall,
            icon: Icon(Icons.videocam, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.grey),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ChatLoadedState) {
                  return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isSentMessage = message.senderId == userId;
                      if (isSentMessage) {
                        return _buildSentMessage(
                          context,
                          message.text,
                          message.image,
                        );
                      } else {
                        return _buildReceivedMessage(
                          context,
                          message.text,
                          message.image,
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
    );
  }

  Widget _buildReceivedMessage(
    BuildContext context,
    String mess,
    List<String>? images,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 38, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildSentMessage(
    BuildContext context,
    String mess,
    List<String>? images,
  ) {
    return Align(
      alignment: Alignment.centerRight,
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
}
