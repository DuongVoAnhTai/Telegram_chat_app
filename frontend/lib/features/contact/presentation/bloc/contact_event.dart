abstract class ContactEvent {}

class FetchContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final String email;

  AddContact(this.email);
}

class CheckCreateConverstaion extends ContactEvent {
  final String contactId;
  final String name;
  CheckCreateConverstaion(this.contactId, this.name);
}
