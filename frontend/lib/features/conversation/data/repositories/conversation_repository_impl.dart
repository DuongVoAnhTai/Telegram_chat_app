import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
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
  @override
  Future<void> createGroupChat(List<String> participantIds, String groupName) async {
    return await converstionRemoteDataSource.createGroupChat(participantIds, groupName);
  }

  @override
  Future<void> addMemberToGroupChat(String conversationId, List<String> userIds) async {
    return await converstionRemoteDataSource.addMemberToGroupChat(conversationId, userIds);
  }

  @override
  Future<void> removeMemberFromGroupChat(String conversationId, String memberId,) async {
    return await converstionRemoteDataSource.removeMemberFromGroupChat(conversationId, memberId,);
  }

  @override
  Future<void> changeConversationName(String conversationId, String newName,) async {
    return await converstionRemoteDataSource.changeConversationName(conversationId, newName,);
  }
  @override
  Future<void> updateGroupProfilePic(String conversationId, String profilePic,) async {
    return await converstionRemoteDataSource.updateGroupProfilePic(conversationId, profilePic,);
  }
  @override
  Future<List<Participant>> getParticipants(String conversationId) async {
    return await converstionRemoteDataSource.getParticipants(conversationId);
  }
}
