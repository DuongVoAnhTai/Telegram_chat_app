import mongoose, { Schema, Document } from 'mongoose';

const ContactSchema = new Schema(
    {
        userId: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
        contactId: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
    },
    {
        timestamps: true,
    }
);

const Contact = mongoose.model('Contact', ContactSchema);

export default Contact;