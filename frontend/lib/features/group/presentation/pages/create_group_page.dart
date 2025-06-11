import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_event.dart';
import 'package:frontend/features/contact/presentation/bloc/contact_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  List<ContactEntity> selectedUsers = [];
  List<ContactEntity> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _showGroupNameDialog() async {
    String groupName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Enter Group Name', style: TextStyle(color: AppColors.textPrimary)),
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
              child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
            ),
            TextButton(
              onPressed: () {
                if (groupName.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name cannot be empty')),
                  );
                  return;
                }
                Navigator.of(context).pop(groupName);
              },
              child: const Text('OK', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        );
      },
    );

    if (groupName.trim().isNotEmpty) {
      if (selectedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one contact')),
        );
        return;
      }
       final selectedIds = selectedUsers.map((user) => user.id).toList();
      try {
        // await _apiService.createGroup(groupName, selectedIds, widget.currentUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "$groupName" created successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Create Group'),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0),
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _showGroupNameDialog,
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
                      final isSelected = selectedUsers.contains(user);
                      return ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          shape: const CircleBorder(),
                          onChanged: (value) {
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
                          children: [const SizedBox(width: 8), Text(user.name)],
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
    );
  }
}
