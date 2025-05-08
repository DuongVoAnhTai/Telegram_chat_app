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

        // Default conversation name: all participants
        let conversationName = participants
            .map((id: mongoose.Types.ObjectId) => nameMap.get(id.toString()) || 'Unknown')
            .join(', ');

        // If it's a one-on-one, exclude current user
        if (participants.length === 2) {
            conversationName = otherParticipants
                .map((id: mongoose.Types.ObjectId) => nameMap.get(id.toString()) || 'Unknown')
                .join(', ');
        }

        const newConversation = new Conversation({
            name: conversationName,
            participants
        });

        const savedConversation = await newConversation.save();


        res.status(201).json(savedConversation);
    } catch (error) {
        res.status(500).json({ message: 'Failed to create conversation', error });
    }
}

// Get conversations of a user
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