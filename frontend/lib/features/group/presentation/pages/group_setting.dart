import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/services/cloudinary.dart';

class GroupSettingPage extends StatefulWidget {
  final String conversationId;
  GroupSettingPage({required this.conversationId});
  @override
  _GroupSettingPageState createState() => _GroupSettingPageState();
}

class _GroupSettingPageState extends State<GroupSettingPage> {
  bool _isUploading = false;
  String? _groupProfilePic;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(GetParticipants(widget.conversationId));
  }

  List<Participant> participants = [];
  // Mock function
  Future<void> _removeMember(String conversationId, String idMember) async {
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(RemoveMembers(conversationId, idMember));
  }

  // Show dialog to select and remove members
  void _showRemoveMemberDialog(List<Participant> members) async {
    if (members.isEmpty) {
      print("empty nè");
      return;
    }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        // State to track selected member
        String? selectedMember;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'Remove Member',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        backgroundImage:
                            member.profilePic != null &&
                                    member.profilePic!.isNotEmpty
                                ? NetworkImage(member.profilePic!)
                                : null,
                        child:
                            member.profilePic == null ||
                                    member.profilePic!.isEmpty
                                ? Text(
                                  member.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                )
                                : null,
                      ),
                      title: Text(
                        member.fullName,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: Radio<String>(
                        value: member.id,
                        groupValue: selectedMember,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMember = value;
                          });
                        },
                      ),
                      onTap: () {
                        setDialogState(() {
                          selectedMember = member.id;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                TextButton(
                  onPressed:
                      selectedMember == null
                          ? null // Disable button if no member is selected
                          : () async {
                            await _removeMember(
                              widget.conversationId,
                              selectedMember ?? "",
                            );
                            if (!mounted) return;
                            Navigator.pop(context); // Close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedMember removed'),
                              ),
                            );
                          },
                  child: Text(
                    'Remove',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        final imageFile = File(pickedFile.path);
        final uploadedUrl = await CloudinaryHelper.uploadImage(imageFile);
        setState(() {
          _groupProfilePic = uploadedUrl;
          _isUploading = false;
        });

        // Update group profile picture
        BlocProvider.of<ConversationBloc>(
          context,
        ).add(UpdateGroupProfilePic(widget.conversationId, uploadedUrl));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group profile picture updated successfully')),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ParticipantsLoaded) {
          setState(() {
            participants = state.participants;
          });
        } else if (state is ConversationError) {
          setState(() {
            print('Error: ${state.message}');
          });
        } else if (state is UpdatedGroupProfilePic) {
          setState(() {
            _groupProfilePic = state.profilePic;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Text('Group Settings'),
        ),
        body: ListView(
          children: [
            _SettingsTile(
              icon: Icons.add_circle_rounded,
              title: "Add Member",
              onTap: () {
                context.push(
                  "/add-member-page?conversationId=${widget.conversationId}",
                );
              },
            ),
            _SettingsTile(
              icon: Icons.remove_circle_rounded,
              title: "Remove Member",
              onTap: () {
                _showRemoveMemberDialog(participants);
              },
            ),
            _SettingsTile(
              icon: Icons.change_circle_outlined,
              title: "Change name group",
              onTap: () {
                _showGroupNameDialog();
              },
            ),
            _SettingsTile(
              icon: Icons.account_circle,
              title: "Change group photo",
              onTap: _isUploading ? null : _pickAndUploadImage,
              trailing:
                  _isUploading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGroupNameDialog() async {
    String groupName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            'Enter Group Name',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            onChanged: (value) {
              groupName = value;
            },
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (groupName.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name cannot be empty')),
                  );
                  return;
                }
                BlocProvider.of<ConversationBloc>(
                  context,
                ).add(ChangeConverName(widget.conversationId, groupName));
                Navigator.of(context).pop(groupName);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      },
    );

    if (groupName.trim().isNotEmpty) {
      try {
        // await _apiService.createGroup(groupName, selectedIds, widget.currentUserId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "$groupName" change successfully')),
        );
        context.pop(groupName);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $error')),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
