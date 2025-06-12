import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../conversation/domain/usecase/check_create_use_case.dart';
import '../../domain/usecase/add_contact_use_case.dart';
import '../../domain/usecase/delete_contact_use_case.dart';
import '../../domain/usecase/fetch_contact_use_case.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final FetchContactUseCase fetchContactUserCase;
  final AddContactUseCase addContactUseCase;
  final CheckCreateUseCase checkCreateUseCase;
  final DeleteContactUseCase deleteContactUseCase;

  ContactBloc({
    required this.fetchContactUserCase,
    required this.addContactUseCase,
    required this.checkCreateUseCase,
    required this.deleteContactUseCase,
  }) : super(ContactInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContact);
    on<CheckCreateConverstaion>(_onCheckCreateConverstaion);
    on<DeleteContact>(_onDeleteContact);
  }

  Future<void> _onFetchContacts(
    FetchContacts event,
    Emitter<ContactState> emit,
  ) async {
    emit(ContactLoading());
    try {
      final contacts = await fetchContactUserCase.call();
      emit(ContactLoaded(contacts));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onAddContact(
    AddContact event,
    Emitter<ContactState> emit,
  ) async {
    emit(ContactLoading());
    try {
      await addContactUseCase(email: event.email);
      emit(ContactAdded());
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onCheckCreateConverstaion(
    CheckCreateConverstaion event,
    Emitter<ContactState> emit,
  ) async {
    try {
      emit(ContactLoading());
      final conversationId = await checkCreateUseCase(event.contactId);

      emit(ConversationReady(conversationId, event.name));
    } catch (error) {
      emit(ContactError(error.toString()));
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await deleteContactUseCase(event.contactId);
      add(FetchContacts()); // Refresh the contact list
    } catch (error) {
      emit(ContactError(error.toString()));
    }
  }
}
