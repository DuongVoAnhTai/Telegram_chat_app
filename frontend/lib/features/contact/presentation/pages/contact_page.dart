import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../bloc/contact_bloc.dart";
import "../bloc/contact_state.dart";

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Page")),
      body: BlocBuilder<ContactBloc, ContactState>(
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
                  onTap: () {},
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
    );
  }
}
