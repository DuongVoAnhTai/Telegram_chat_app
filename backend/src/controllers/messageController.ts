import Conversation from "../models/conversationModel";
import Message from "../models/messageModel";
import User from "../models/userModel";
import cloudinary from "../config/cloudinary";
import { sendMessageLogic } from "../config/messageService";

export const getUsersForSidebar = async (req: any, res: any) => {
    try {
        const loggedInUserId = req.user.id;
        const filteredUsers = await User.find({ _id: { $ne: loggedInUserId } })

        res.status(200).json(filteredUsers);
    } catch (error) {
        res.status(500).json({ error: "internal server error" });
    }
}

export const getMessages = async (req: any, res: any) => {
    try {
        const { id: conversationId } = req.params;
        const messages = await Message.find({
            conversationId: conversationId,
        });
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({ error: "internal server error" });
    }
}

export const sendMessage = async (req: any, res: any) => {
    try {
        const { text, images } = req.body;
        const { id: conversationId } = req.params;
        const senderId = req.user._id;

        const newMessage = await sendMessageLogic(text, images, senderId, conversationId);
        //TODO: realtime functionality gose here => socket.io

        res.status(201).json(newMessage);

    } catch (error) {
        res.status(500).json({ error: "internal server error" });
        console.log(error);
    }
}