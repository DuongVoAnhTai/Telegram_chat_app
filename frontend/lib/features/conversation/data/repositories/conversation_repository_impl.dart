import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';
import 'package:frontend/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:flutter/material.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource converstionRemoteDataSource;

  ConversationRepositoryImpl({required this.converstionRemoteDataSource});
  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    return await converstionRemoteDataSource.fetchConversations();
  }

  @override
  Future<void> createConversations(String participantId) async {
    return await converstionRemoteDataSource.createConversations(participantId);
  }

  @override
  Future<String> checkCreateConversation(String contactId) async {
    return await converstionRemoteDataSource.checkCreateConversation(contactId);
  }
}
