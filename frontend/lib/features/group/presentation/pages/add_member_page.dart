import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_event.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_state.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';

class AddMemberPage extends StatefulWidget {
  final String conversationId;
  final List<String> existingMemberIds;

  AddMemberPage({
    required this.conversationId,
    required this.existingMemberIds,
  });

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  ContactEntity? selectedUser;
  List<ContactEntity> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    filteredUsers = [];
    _searchController.addListener(_filterUsers);
    BlocProvider.of<ContactBloc>(context).add(FetchContacts());
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
    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }
    final participantId = selectedUser!.userId;
    BlocProvider.of<ConversationBloc>(context).add(
      AddMemberToGroupChat(widget.conversationId, participantId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ConversationLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adding members...')),
          );
        } else if (state is MembersAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Members added successfully')),
          );
          Navigator.pop(context);
        } else if (state is ConversationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add members: ${state.message}')),
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
                    filteredUsers =
                      _isSearching
                          ? state.contacts
                              .where(
                                (contact) =>
                                    contact.name.toLowerCase().contains(
                                      _searchController.text.toLowerCase(),
                                    ),
                              )
                              .toList()
                          : state.contacts;
                    if (filteredUsers.isEmpty) {
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
                        return ListTile(
                          leading: Radio<ContactEntity>(
                            value: user,
                            groupValue: selectedUser,
                            onChanged: (ContactEntity? value) {
                              setState(() {
                                selectedUser = value;
                              });
                            },
                          ),
                          title: Row(
                            children: [
                              Text(user.name),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedUser = user;
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