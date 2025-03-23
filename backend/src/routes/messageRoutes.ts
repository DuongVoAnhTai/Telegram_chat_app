import express from "express";
import MessageController from "../app/controllers/MessageController";

const router = express.Router();

// API REST: Lấy tất cả tin nhắn
// router.get("/messages", async (req, res) => {
//   try {
//     const messages = await Message.find();
//     res.json(messages);
//   } catch (err) {
//     console.error("Error fetching messages:", err);
//     res.status(500).json({ error: "Internal server error" });
//   }
// });

router.get('/messages', MessageController.show);

export default router;
