import mongoose, { Schema } from 'mongoose';

const conversationSchema = new Schema(
    {
        participants: [
            {
                type: mongoose.Schema.Types.ObjectId,
                required: true,
                ref: 'User',
            }
        ],
        text: {
            type: String,
        },
        iconUrl: {
            type: String,
        },
        lastMessage: {
            messageId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Message",
            },
            senderId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: "User",
            },
        },
        admin: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "User",
                required: true,
            }
        ]
    },
    { timestamps: true }
);

const ConversationSchema = mongoose.model("Conversations", conversationSchema);

export default ConversationSchema;