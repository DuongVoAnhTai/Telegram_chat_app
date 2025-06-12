import mongoose, { Schema, Document } from 'mongoose';

export interface IConversation extends Document {
  ownerID: mongoose.Types.ObjectId;
  name: string;
  participants: mongoose.Types.ObjectId[];
  lastMessage: string;
  updatedAt: Date;
  savedMessagesId: mongoose.Types.ObjectId;
  isDeleted: Boolean;
  deletedAt: Date;
  profilePic: string;
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
        ownerID: {
            type: mongoose.Types.ObjectId,
            ref: 'User',
            require: false,
        },
        isDeleted: {
            type: Boolean,
            default: false,
        },
        deletedAt: {
            type: Date,
            require: false,
        },
        profilePic: {
            type: String,
            default: "",
          },
    },
    {
        timestamps: true,
    }
);

const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema);

export default Conversation;