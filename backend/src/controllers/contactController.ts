import { Request, Response } from 'express';
import Contact from '../models/contactModel';
import User from '../models/userModel';
import Message from '../models/messageModel';
import Conversation from '../models/conversationModel';
import { io } from '../config/socket';

// Get all contacts
export const fetchContacts = async (req: any, res: any) => {
    let userId = null;
    if (req.user) {
        userId = req.user._id;
    }
    try {
        const contacts = await Contact.find({ userId: userId }).populate('contactId', 'fullName email');
        res.status(200).json(contacts);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching contacts', error });
    }
};

// Get a single contact by ID
export const getContactById = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const contact = await Contact.findOne({ _id: id });
        if (!contact) {
            return res.status(404).json({ message: 'Contact not found' });
        }
        res.status(200).json(contact);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching contact', error });
    }
};

// Create a new contact
export const createContact = async (req: any, res: Response) => {
    try {
        let userId = null;
        if (req.user) {
            userId = req.user._id;
        }
        const { contactEmail } = req.body;

        const contactId = await User.findOne({ email: contactEmail });

        const newContact = new Contact({
            userId: req.user._id,
            contactId: contactId,
        });
        const result = await newContact.save();
        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ message: 'Error creating contact', error });
    }
};

// Update a contact by ID
export const updateContact = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const updatedContact = req.body;
        const result = await Contact.updateOne(
            { _id: id },
            { $set: updatedContact }
        );
        if (result.matchedCount === 0) {
            return res.status(404).json({ message: 'Contact not found' });
        }
        res.status(200).json({ message: 'Contact updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating contact', error });
    }
};

// Delete a contact by ID and all associated data
export const deleteContact = async (req: any, res: any) => {
    try {
        const { id } = req.params;
        const contact = await Contact.findById(id);

        if (!contact) {
            return res.status(404).json({ message: 'Contact not found' });
        }

        // Find all conversations between the user and contact
        const conversations = await Conversation.find({
            participants: {
                $all: [req.user._id, contact.contactId]
            }
        });

        // Delete all messages in these conversations
        for (const conversation of conversations) {
            await Message.deleteMany({ conversationId: conversation._id });
        }

        // Delete the conversations
        await Conversation.deleteMany({
            _id: { $in: conversations.map(c => c._id) }
        });

        // Finally delete the contact
        await Contact.deleteOne({ _id: id });

        io.emit('updateConversations');

        res.status(200).json({ message: 'Contact and associated data deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting contact', error });
    }
};