import { Request, Response } from "express"
import { CallLog } from "../models/callLogModel";
export const startCall = async (req: Request, res: Response) => {
  try {
    const { userId, conversationId, callType } = req.body;

    if (!userId || !conversationId) {
        res.status(400).json({ message: "Missing required fields" });
      return 
    }

    const call = await CallLog.create({
      userId,
      conversationId,
      callType: callType || "video",
      startedAt: new Date(),
    });

    res.status(201).json(call);
  } catch (error) {
    console.error(error);
    res.status(500).json("Server error");
  }
};
export const endCall = async (req: Request, res: Response) => {
  try {
    const { conversationId, userId } = req.body;

    if (!conversationId || !userId ) {
        res.status(400).json({ message: "Missing conversationId or userId" });
      return 
    }

    const updatedCall = await CallLog.findOneAndUpdate(
      { conversationId: conversationId, userId: userId },
      { endedAt: new Date() },
      { new: true } // Trả về bản ghi đã cập nhật
    );

    if (!updatedCall) {
        res.status(404).json({ message: "Call not found" });
      return 
    }
    updatedCall.endedAt = new Date();
    await updatedCall.save();
    res.status(200).json(updatedCall);
  } catch (error) {
    console.error(error);
    res.status(500).json("Server error");
  }
};
export const recentCall = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    const calls = await CallLog.find({ userId })
      .sort({ startedAt: -1 }) // mới nhất trước
      .limit(20); // Giới hạn số log trả về

    res.status(200).json(calls);
  } catch (error) {
    console.error(error);
    res.status(500).json("Server error");
  }
};