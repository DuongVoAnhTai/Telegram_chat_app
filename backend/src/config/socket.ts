import { Server } from 'socket.io';
import http from 'http';
import express from 'express';
import { sendMessage } from '../controllers/messageController';
import { sendMessageLogic } from './messageService';
import Message from '../models/messageModel';
import Conversation from '../models/conversationModel';

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: ["http://10.0.2.2:3000"]
    }
});

io.on("connection", (socket) => {
    console.log("A user connected", socket.id);


    socket.on("joinConversation", (conversationId) => {
        socket.join(conversationId);
        console.log(`User ${socket.id} joined room ${conversationId}`);
    });

    socket.on("sendMessage", async (message) => {
        const { conversationId, senderId, text, image } = message;
        try {
            const send = await sendMessageLogic(text, image, senderId, conversationId);
            console.log("Message sent to room ${conversationId}:", send);
            io.to(conversationId).emit("newMessage", send);
            io.emit("updateConversations", {
                conversationId,
                lastMessage: send.text || (send.image.length > 0 ? "images" : ""),
                lastMessageTime: send.createdAt,
            });
        } catch (error) {
            console.error("Error sending message:", error);
            return;
        }
    });

    socket.on("deleteMessage", async (data) => {
        const { messageId, conversationId } = data;
        try {
            await Message.findByIdAndDelete(messageId);
            var conversation = await Conversation.findById(conversationId);
            if (conversation) {
                conversation.lastMessage = "deleted";
                await conversation.save();
            }
            io.to(conversationId).emit("messageDeleted", { messageId });
            io.emit("updateConversations", {
                conversationId,
                lastMessage: "deleted",
                lastMessageTime: new Date(),
            });
        } catch (error) {
            console.error("Error deleting message:", error);
        }
    });

    socket.on("deleteConversation", async (conversationId) => {
        try {
            await Message.deleteMany({ conversationId: conversationId });
            await Conversation.findByIdAndDelete(conversationId);
            io.emit("updateConversations");
        } catch (error) {
            console.error("Error deleting conversation:", error);
        }
    });

    socket.on("disconnect", () => {
        console.log("A user disconnected", socket.id);
    })

});

export { io, app, server };