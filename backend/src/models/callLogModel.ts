import mongoose, { Schema, Document } from "mongoose";

// Interface cho TypeScript
export interface ICallLog extends Document {
  userId: string;
  conversationId: string;
  startedAt: Date;
  endedAt?: Date;
  callType: "video" | "audio";
}

// Mongoose Schema
const callLogSchema = new Schema<ICallLog>({
  userId: { type: String, ref: "User", required: true },
  conversationId: { type: String, ref: "Conversation", required: true },
  startedAt: { type: Date, required: true, default: Date.now },
  endedAt: { type: Date },
  callType: { type: String, enum: ["video", "audio"], default: "video" },
});

// Tạo model
export const CallLog = mongoose.model<ICallLog>("CallLog", callLogSchema);
