import { Request, Response } from 'express';
import Conversation from '../models/conversationModel';
import mongoose from 'mongoose';
import User from '../models/userModel';

export const createConversation = async (req: any, res: any) => {
    try {
        let userId = null;
        if (req.user) {
            userId = req.user._id;
        }

        // const { participants } = req.body;

        // const otherParticipants = participants.filter(
        //     (participant: mongoose.Types.ObjectId) => participant.toString() !== userId.toString()
        // );
        // var newConversation = new Conversation({ name: participants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
        // if (participants.length == 2) {
        //     newConversation = new Conversation({ name: otherParticipants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
        // }
        // const savedConversation = await newConversation.save();

        const { participants } = req.body;

        // Remove the current user from the list for naming
        const otherParticipants = participants.filter(
            (participant: mongoose.Types.ObjectId) => participant.toString() !== userId.toString()
        );

        // Fetch user names from DB
        const users = await User.find({ _id: { $in: participants } }).select('fullName');

        const nameMap = new Map(users.map(user => [user._id.toString(), user.fullName]));

        const { groupName } = req.body;
        let conversationName = "";
        if (!groupName) {
            // If groupName is provided, use it; otherwise, generate a default name
            // Default conversation name: all participants
            conversationName = participants
                .map((id: mongoose.Types.ObjectId) => nameMap.get(id.toString()) || 'Unknown')
                .join(', ');

            // If it's a one-on-one, exclude current user
            if (participants.length === 2) {
                conversationName = otherParticipants
                    .map((id: mongoose.Types.ObjectId) => nameMap.get(id.toString()) || 'Unknown')
                    .join(', ');
            }
        } else {
            // If groupName is provided, use it
            conversationName = groupName;
        }


        const newConversation = new Conversation({
            name: conversationName,
            participants,
            ownerID: req.user._id
        });

        const savedConversation = await newConversation.save();


        res.status(201).json(savedConversation);
    } catch (error) {
        res.status(500).json({ message: 'Failed to create conversation', error });
    }
}

export const addMemberToConversation = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const { newMemberId } = req.body;

        if (!conversationId || !newMemberId || typeof conversationId !== 'string' || typeof newMemberId !== 'string') {
            res.status(400).json({ message: 'conversationId and newMemberId must be non-empty strings' });
            return;
        }

        const conversationObjectId = new mongoose.Types.ObjectId(conversationId);
        const newMemberObjectId = new mongoose.Types.ObjectId(newMemberId);

        console.log(conversationId);

        const conversation = await Conversation.findById(conversationObjectId);
        if (!conversation) {
            res.status(404).json({ message: 'Conversation not found' });
            console.log("Conversation not found");
            return;
        }

        const alreadyParticipant = conversation.participants.some((participantId: mongoose.Types.ObjectId) =>
            participantId.equals(newMemberObjectId)
        );

        if (alreadyParticipant) {
            res.status(400).json({ message: 'User is already a participant in the conversation' });
            console.log("User is already a participant in the conversation");
            return;
        }

        conversation.participants.push(newMemberObjectId);

        // Cập nhật tên (nếu là group có nhiều người)
        const users = await User.find({ _id: { $in: conversation.participants } }).select('fullName');
        const nameMap = new Map(users.map(user => [user._id.toString(), user.fullName]));

        // Chỉ cập nhật tên nếu conversation.name rỗng hoặc không tồn tại
        if (!conversation.name || conversation.name.trim() === '') {
        conversation.name = conversation.participants
            .map(id => nameMap.get(id.toString()) || 'Unknown')
            .join(', ');
        }

        const updatedConversation = await conversation.save();

        res.status(200).json(updatedConversation);
    } catch (error) {
        console.error('Error in addMemberToConversation:', error);
        res.status(500).json({ message: 'Failed to add member to conversation', error });
    }
};

export const getUserConversations = async (req: Request, res: Response) => {
    try {
        const { id: userId } = req.params;
        const conversations = await Conversation.find({ participants: { $in: [userId] } }).populate("participants", "fullName profilePic");
        res.status(200).json(conversations);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch conversations', error });
    }
}

// Get a conversation between two users
export const getConversationBetweenUsers = async (req: Request, res: Response) => {
    try {
        const { userId1, userId2 } = req.body;

        const conversation = await Conversation.findOne({
            participants: { $all: [userId1, userId2] },
        });

        if (!conversation) {
            res.status(404).json({ message: 'Conversation not found' });
            return;
        }

        res.status(200).json(conversation);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch conversation', error });
    }
}
export const getParticipantConversations = async (req: Request, res: Response) => {
  try {
    const { conversationId } = req.params;
    const conversation = await Conversation.findOne({ _id: conversationId })
      .populate('participants', 'fullName profilePic')
    if (!conversation) {
        res.status(404).json({ message: 'Conversation not found' });
      return ;
    }
     // Trích xuất _id và fullName từ participants
    const participants = conversation.participants.map((participant: any) => ({
      _id: participant._id.toString(),
      fullName: participant.fullName,
      profilePic: participant.profilePic,
    }));
    res.status(200).json({ participants });
  } catch (error) {
    console.error('Error fetching participants:', error);
    res.status(500).json({ message: 'Failed to fetch participants', error });
  }
};
export const checkOrCreateConversation = async (req: any, res: any) => {
    try {
        let userId = null;
        if (req.user) {
            userId = req.user._id;
        }

        const { contactId } = req.body;

        // Check if the conversation already exists
        const existingConversation = await Conversation.findOne({
            participants: { $all: [userId, contactId] },
        });

        if (existingConversation) {
            return res.status(200).json(existingConversation);
        }

        // If not, create a new conversation
        const newConversation = new Conversation({
            participants: [userId, contactId],
        });
        const savedConversation = await newConversation.save();

        res.status(201).json(savedConversation);
    } catch (error) {
        res.status(500).json({ message: 'Failed to check or create conversation', error });
    }
}

export const createNewConversationSavedMessageForNewUser = async (userId: string) => {
    try {
        const existing = await Conversation.findOne({
            participants: [userId],
            name: "Saved Messages",
        });
        if (existing) {
            return existing;
        }
        const newConversation = await Conversation.create({
            name: "Saved Messages",
            participants: [userId],
            lastMessage: "",
        });
        newConversation.savedMessagesId = newConversation._id as mongoose.Types.ObjectId;
        await newConversation.save();

        return newConversation;
    } catch (error) {
        console.error("Error creating saved message conversation:", error);
        throw error;
    }
} 