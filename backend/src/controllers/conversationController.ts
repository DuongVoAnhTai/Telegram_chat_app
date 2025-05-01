import { Request, Response } from 'express';
import Conversation from '../models/conversationModel';
import mongoose from 'mongoose';

export const createConversation = async (req: any, res: any) => {
    try {
        let userId = null;
        if (req.user) {
            userId = req.user._id;
        }

        const { participants } = req.body;

        const otherParticipants = participants.filter(
            (participant: mongoose.Types.ObjectId) => participant.toString() !== userId.toString()
        );
        var newConversation = new Conversation({ name: participants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
        if (participants.length == 2) {
            newConversation = new Conversation({ name: otherParticipants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
        }
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
        const conversations = await Conversation.find({ participants: { $in: [userId] } });
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

export const checkOrCreateConversation = async (req: any, res: Response) => {
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