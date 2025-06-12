import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_event.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_state.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';

class AddMemberPage extends StatefulWidget {
  final String conversationId;

  AddMemberPage({required this.conversationId});

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  List<ContactEntity> selectedUsers = [];
  List<ContactEntity> filteredUsers = [];
  List<Participant> currentParticipants = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    filteredUsers = [];
    _searchController.addListener(_filterUsers);
    BlocProvider.of<ContactBloc>(context).add(FetchContacts());
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(GetParticipants(widget.conversationId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  Future<void> _addMembers() async {
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }
    List<String> userIds = [];
    for(var u in selectedUsers) {
      userIds.add(u.userId);
    }
    BlocProvider.of<ConversationBloc>(
      context,
    ).add(AddMemberToGroupChat(widget.conversationId, userIds));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ParticipantsLoaded) {
          setState(() {
            currentParticipants = state.participants;
          });
        } else if (state is MembersAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Members added successfully')),
          );
          Navigator.pop(context);
        } else if (state is ConversationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Add Members'),
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 20.0),
              icon: const Icon(Icons.person_add),
              onPressed: _addMembers,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state is ContactLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ContactLoaded) {
                    // Tạo Set chứa id của những người đã tham gia group
                    final participantIds =
                        currentParticipants.map((e) => e.id).toSet();
                    // Lọc ra những contact chưa nằm trong currentParticipants
                    final availableContacts =
                        state.contacts
                            .where(
                              (contact) =>
                                  !participantIds.contains(contact.userId),
                            )
                            .toList();
                    filteredUsers =
                        _isSearching
                            ? availableContacts
                                .where(
                                  (contact) =>
                                      contact.name.toLowerCase().contains(
                                        _searchController.text.toLowerCase(),
                                      ),
                                )
                                .toList()
                            : availableContacts;
                    if (filteredUsers.isEmpty || availableContacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? "No contact found"
                                  : "No contact yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isSelected = selectedUsers.contains(
                          user,
                        ); // selectedUsers là List<ContactEntity>

                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedUsers.add(user);
                                } else {
                                  selectedUsers.remove(user);
                                }
                              });
                            },
                          ),
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                backgroundImage:
                                    user.profilePic != null &&
                                            user.profilePic!.isNotEmpty
                                        ? NetworkImage(user.profilePic!)
                                        : null,
                                child:
                                    user.profilePic == null ||
                                            user.profilePic!.isEmpty
                                        ? Text(
                                          user.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.white,
                                          ),
                                        )
                                        : null,
                              ),
                              SizedBox(width: 10,),
                              Text(user.name),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedUsers.remove(user);
                              } else {
                                selectedUsers.add(user);
                              }
                            });
                          },
                        );
                      },
                    );
                  } else if (state is ContactError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return const Center(child: Text('No contacts found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
