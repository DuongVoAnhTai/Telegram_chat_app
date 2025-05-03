import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../conversation/domain/usecase/check_create_use_case.dart';
import '../../../conversation/presentation/bloc/conversation_event.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/usecase/add_contact_use_case.dart';
import '../../domain/usecase/fetch_contact_use_case.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final FetchContactUseCase fetchContactUserCase;
  final AddContactUseCase addContactUseCase;
  final CheckCreateUseCase checkCreateUseCase;

  ContactBloc({
    required this.fetchContactUserCase,
    required this.addContactUseCase,
    required this.checkCreateUseCase,
  }) : super(ContactInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContact);
    on<CheckCreateConverstaion>(_onCheckCreateConverstaion);
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
}
