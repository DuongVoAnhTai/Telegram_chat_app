import 'package:frontend/features/contact/domain/entities/contact_entity.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final List<ContactEntity> contacts;

  ContactLoaded(this.contacts);
}

class ContactError extends ContactState {
  final String message;

  ContactError(this.message);
}

class ContactAdded extends ContactState {}

class ConversationReady extends ContactState {
  final String conversatoinId;
  final String name;
  ConversationReady(this.conversatoinId, this.name);
}
