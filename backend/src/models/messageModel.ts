import mongoose, { Schema } from 'mongoose';

const messageSchema = new Schema(
    {
        senderId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: "User",
        },
        conversationId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: "Conversation",
        },
        text: {
            type: String,
        },
        image: {
            type: String,
        },
    },
    { timestamps: true }
);

const Message = mongoose.model("Messages", messageSchema);

export default Message;