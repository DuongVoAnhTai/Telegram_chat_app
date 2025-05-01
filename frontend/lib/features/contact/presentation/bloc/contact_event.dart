abstract class ContactEvent {}

class FetchContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final String contactId;

  AddContact(this.contactId);
}
