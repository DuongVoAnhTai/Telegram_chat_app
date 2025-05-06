import mongoose, { Schema, Document } from 'mongoose';

export interface IConversation extends Document {
    name: string;
    participants: mongoose.Types.ObjectId[];
    lastMessage: string;
    updatedAt: Date;
    savedMessagesId: mongoose.Types.ObjectId;
}

const ConversationSchema: Schema = new Schema(
    {
        name: {
            type: String,
            default: '',
        },
        participants: [
            {
                type: mongoose.Types.ObjectId,
                ref: 'User',
                required: true,
            },
        ],
        lastMessage: {
            type: String,
            default: '',
        },
        savedMessagesId: {
            type: mongoose.Types.ObjectId,
        },
    },
    {
        timestamps: true,
    }
);

const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema);

export default Conversation;