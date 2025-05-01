import { v2 as cloudinary } from 'cloudinary';
import Message from '../models/messageModel';
import Conversation from '../models/conversationModel';

export const sendMessageLogic = async (
    text: string,
    image: string,
    senderId: string,
    conversationId: string
) => {
    let imageUrl = "";

    if (image || image !== '') {
        const uploadResponse = await cloudinary.uploader.upload(image);
        imageUrl = uploadResponse.secure_url;
    }

    const newMessage = new Message({
        senderId,
        conversationId,
        text,
        image: imageUrl,
    });

    const conver = await Conversation.findOne({ _id: conversationId });
    if (conver) {
        conver.lastMessage = !text ? "image" : text;
        conver.updatedAt = newMessage.createdAt;
        await conver.save();
    }

    await newMessage.save();

    return newMessage;
};
