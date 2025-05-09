import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:frontend/features/contact/presentation/bloc/contact_event.dart";
import "package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart";
import "package:frontend/features/conversation/presentation/bloc/conversation_event.dart";
import "package:go_router/go_router.dart";
import "package:frontend/features/auth/presentation/bloc/auth_bloc.dart";
import "package:frontend/features/auth/presentation/bloc/auth_state.dart";

import "../bloc/contact_bloc.dart";
import "../bloc/contact_state.dart";

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactBloc>(context).add(FetchContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Page")),
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ConversationReady) {
            context.pop();
            context.push(
              "/chat-page?id=${state.conversatoinId}&mate=${state.name}",
            );
          } else if (state is ContactAdded) {
            // After contact is added successfully, fetch the updated list
            BlocProvider.of<ContactBloc>(context).add(FetchContacts());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            BlocProvider.of<ContactBloc>(context).add(FetchContacts());
          }
        },
        child: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContactLoaded) {
              return ListView.builder(
                itemCount: state.contacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.contacts[index].name),
                    subtitle: Text(state.contacts[index].email),
                    onTap: () {
                      BlocProvider.of<ContactBloc>(context).add(
                        CheckCreateConverstaion(
                          state.contacts[index].userId,
                          state.contacts[index].name,
                        ),
                      );
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Contact'),
                            content: Text(
                              'Are you sure you want to delete this contact? This will also delete all conversations and messages with this contact.',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  BlocProvider.of<ContactBloc>(context).add(
                                    DeleteContact(state.contacts[index].id),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
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
                    },
                  );
                },
              );
            } else {
              return const Center(child: Text("No contacts found"));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String? currentUserEmail;
              if (authState is ProfileLoaded) {
                currentUserEmail = authState.user.email;
              }

              return AlertDialog(
                title: const Text('Add contact'),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter contact email',
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      // Basic email validation
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      // Check if user is trying to add their own email
                      if (currentUserEmail != null &&
                          value.trim() == currentUserEmail) {
                        return 'You cannot add your own email';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        BlocProvider.of<ContactBloc>(
                          context,
                        ).add(AddContact(email));
                        context.pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
