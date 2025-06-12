import { v2 as cloudinary } from 'cloudinary';
import Message from '../models/messageModel';
import Conversation from '../models/conversationModel';

export const sendMessageLogic = async (
    text: string,
    images: string[], // Changed from string to string[]
    senderId: string,
    conversationId: string
) => {
    const imageUrls = images.filter(img => img && img.startsWith('https://res.cloudinary.com'));

    const newMessage = new Message({
        senderId,
        conversationId,
        text,
        image: imageUrls, // Store array of image URLs
    });

    const conver = await Conversation.findOne({ _id: conversationId });
    if (conver) {
        conver.lastMessage = !text ? (imageUrls.length > 0 ? "images" : "") : text;
        conver.updatedAt = newMessage.createdAt;
        await conver.save();
    }

    await newMessage.save();

    return newMessage;
};
