import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:frontend/features/contact/presentation/bloc/contact_event.dart";
import "package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart";
import "package:frontend/features/conversation/presentation/bloc/conversation_event.dart";
import "package:go_router/go_router.dart";

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
                  );
                },
              );
            } else if (state is ContactError) {
              return Center(child: Text(state.message));
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add contact'),
            content: TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Enter contact email'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  //Navigate back
                  context.pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    BlocProvider.of<ContactBloc>(
                      context,
                    ).add(AddContact(email));
                    BlocProvider.of<ContactBloc>(context).add(FetchContacts());
                    //Navigate back
                    context.pop();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }
}
