import mongoose from "mongoose";

const Schema = mongoose.Schema;

const messageSchema = new Schema({
    content: String,
    sender: String,

}, {
    timestamps: true
});

export const Message = mongoose.model("Message", messageSchema);

